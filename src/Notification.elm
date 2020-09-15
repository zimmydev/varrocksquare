module Notification exposing (Id, Notification(..), canSilence, expire, id, loggedIn, loggedOut, notify, passwordsDontMatch, payload, receivedMessage, view)

import Api exposing (AuthToken)
import Config.App as App
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (Attribute, Color, Element)
import Icon exposing (Icon)
import Process
import Task
import Time
import Username exposing (Username)
import Utils.String exposing (abridge)


type Notification
    = Info String Id
    | Success String Id
    | Error String Id
    | ReceivedMessage String Id


type alias Id =
    Int


canSilence : Notification -> Bool
canSilence notif =
    case notif of
        ReceivedMessage _ _ ->
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


receivedMessage : AuthToken -> Username -> String -> Id -> Notification
receivedMessage _ sender mess =
    let
        preview =
            abridge App.messagePreviewLength mess
    in
    ReceivedMessage (Username.toString sender ++ ": " ++ preview)



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

        ReceivedMessage _ i ->
            i


payload : Notification -> String
payload notif =
    case notif of
        Info pl _ ->
            pl

        Success pl _ ->
            pl

        Error pl _ ->
            pl

        ReceivedMessage pl _ ->
            pl



-- TRANSFORM


view : Notification -> Element msg
view notif =
    let
        ( icon, color ) =
            style notif
    in
    Element.el (Styles.notification color) <|
        Element.row [ Styles.smallSpacing ]
            [ Icon.view icon, Element.text (payload notif) ]



-- COMMANDS


notify : (Id -> Notification) -> (Notification -> msg) -> Cmd msg
notify notif fireNotif =
    Time.now
        |> Task.map Time.posixToMillis
        |> Task.perform (notif >> fireNotif)


expire : Notification -> (Notification -> msg) -> Cmd msg
expire notif expireNotif =
    Process.sleep 5000
        |> Task.perform (always (expireNotif notif))



-- HELPER


style : Notification -> ( Icon, Color )
style notif =
    let
        size =
            Icon.Small
    in
    case notif of
        Info _ _ ->
            ( Icon.espresso size, Colors.black )

        Success _ _ ->
            ( Icon.success size, Colors.green )

        Error _ _ ->
            ( Icon.error size, Colors.red )

        ReceivedMessage _ _ ->
            ( Icon.envelope size, Colors.blue )
