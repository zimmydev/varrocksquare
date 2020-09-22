module Alert exposing (Alert(..), Id, canSilence, expire, fire, id, loggedIn, loggedOut, passwordsDontMatch, payload, receivedMessage, view)

import Api exposing (AuthToken)
import Config.App as App
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (Color, Element)
import Icon exposing (Icon)
import Process
import Task
import Time
import Username exposing (Username)
import Utils.String exposing (abridge)


type Alert
    = Info String Id
    | Success String Id
    | Error String Id
    | ReceivedMessage String Id


type alias Id =
    Int



-- Obtaining an Alert


loggedOut : Id -> Alert
loggedOut =
    Info "Logged out."


loggedIn : Username -> Id -> Alert
loggedIn username =
    Success ("Welcome back, " ++ Username.toString username ++ "!")


passwordsDontMatch : Id -> Alert
passwordsDontMatch =
    Error "The password fields don't match one another!"


receivedMessage : AuthToken -> Username -> String -> Id -> Alert
receivedMessage _ sender mess =
    let
        preview =
            abridge App.messagePreviewLength mess
    in
    ReceivedMessage (Username.toString sender ++ ": " ++ preview)



-- Info on Alert


id : Alert -> Id
id alert =
    case alert of
        Info _ i ->
            i

        Success _ i ->
            i

        Error _ i ->
            i

        ReceivedMessage _ i ->
            i


payload : Alert -> String
payload alert =
    case alert of
        Info pl _ ->
            pl

        Success pl _ ->
            pl

        Error pl _ ->
            pl

        ReceivedMessage pl _ ->
            pl


canSilence : Alert -> Bool
canSilence alert =
    case alert of
        ReceivedMessage _ _ ->
            True

        _ ->
            False



-- Converting an Alert


view : Alert -> Element msg
view alert =
    let
        ( icon, color ) =
            style alert
    in
    Element.el (Styles.alert color) <|
        Element.row [ Styles.smallSpacing ]
            [ Icon.view icon, Element.text (payload alert) ]



-- Commands


fire : (Alert -> msg) -> (Id -> Alert) -> Cmd msg
fire alertFired alert =
    Time.now
        |> Task.map Time.posixToMillis
        |> Task.perform (alert >> alertFired)


expire : Float -> (Alert -> msg) -> Alert -> Cmd msg
expire timeout expireAlert alert =
    Process.sleep timeout
        |> Task.perform (always (expireAlert alert))



-- Helpers


style : Alert -> ( Icon, Color )
style alert =
    let
        size =
            Icon.Small
    in
    case alert of
        Info _ _ ->
            ( Icon.espresso size, Colors.black )

        Success _ _ ->
            ( Icon.success size, Colors.green )

        Error _ _ ->
            ( Icon.error size, Colors.red )

        ReceivedMessage _ _ ->
            ( Icon.envelope size, Colors.blue )
