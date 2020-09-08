module Notification exposing (Id, Notification(..), canSilence, delayFor, expire, id, loggedIn, loggedOut, notify, passwordsDontMatch, payload, receivedLink, receivedMessage, view)

import Config.App as App
import Config.Links exposing (Href)
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (Attribute, Color, Element)
import Icon exposing (Icon)
import Process
import Task
import Time
import Username exposing (Username)
import Viewer exposing (Viewer)


type Notification
    = Info String Id
    | Success String Id
    | Error String Id
    | ReceivedMessage String Viewer Id
    | ReceivedLink String Href Viewer Id



{-
   type Notification
       = Notification Category String Id


   type Category
       = Info
       | Success
       | Error
       | Message -- These notifications are noisy but can be silenced
-}


type alias Id =
    Int


canSilence : Notification -> Bool
canSilence notif =
    case notif of
        ReceivedMessage _ _ _ ->
            True

        ReceivedLink _ _ _ _ ->
            True

        _ ->
            False



-- NOTIFICATIONS (CREATION)


loggedOut : Id -> Notification
loggedOut =
    Info "Logged out."


loggedIn : Username -> Id -> Notification
loggedIn username =
    Success ("Welcome back, " ++ Username.toString username ++ "!")


passwordsDontMatch : Id -> Notification
passwordsDontMatch =
    Error "The password fields don't match one another!"


receivedMessage : Username -> String -> Viewer -> Id -> Notification
receivedMessage sender mess =
    let
        charBalance =
            String.length mess - App.messagePreviewLength

        preview =
            if charBalance > 0 then
                String.trimRight (String.dropRight charBalance mess) ++ "…"

            else
                mess
    in
    ReceivedMessage (Username.toString sender ++ ": " ++ preview)


receivedLink : Username -> String -> Href -> Viewer -> Id -> Notification
receivedLink sender title =
    ReceivedLink (Username.toString sender ++ " sent you a link: " ++ title)



-- INFO


id : Notification -> Id
id notif =
    case notif of
        Info _ i ->
            i

        Success _ i ->
            i

        Error _ i ->
            i

        ReceivedMessage _ _ i ->
            i

        ReceivedLink _ _ _ i ->
            i


payload : Notification -> String
payload notif =
    case notif of
        Info str _ ->
            str

        Success str _ ->
            str

        Error str _ ->
            str

        ReceivedMessage str _ _ ->
            str

        ReceivedLink str _ _ _ ->
            str



-- TRANSFORM


view : Notification -> Element msg
view notif =
    let
        ( icon, color ) =
            visualElements notif
    in
    Element.el (Styles.notification color) <|
        Element.row Styles.labeledElement
            [ Icon.view icon, Element.text (payload notif) ]



-- COMMANDS


notify : (Id -> Notification) -> (Notification -> msg) -> Cmd msg
notify notif fireNotif =
    Time.now
        |> Task.map Time.posixToMillis
        |> Task.perform (notif >> fireNotif)


expire : Notification -> (Notification -> msg) -> Cmd msg
expire notif expireNotif =
    delayFor notif
        |> Process.sleep
        |> Task.perform (always (expireNotif notif))


delayFor : Notification -> Float
delayFor notif =
    notif
        |> payload
        |> String.length
        |> toFloat
        |> (*) 50
        |> (+) 3500
        |> min 60000



-- HELPER


visualElements : Notification -> ( Icon, Color )
visualElements notif =
    let
        size =
            Icon.small
    in
    case notif of
        Info _ _ ->
            ( Icon.espresso size, Colors.black )

        Success _ _ ->
            ( Icon.success size, Colors.green )

        Error _ _ ->
            ( Icon.error size, Colors.red )

        ReceivedMessage _ _ _ ->
            ( Icon.envelope size, Colors.blue )

        ReceivedLink _ _ _ _ ->
            ( Icon.linkEnvelope size, Colors.indigo )
