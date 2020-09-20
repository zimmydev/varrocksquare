module Page.Settings exposing (Model, Msg(..), initCommands, initModel, update, view)

import Browser.Navigation as Nav
import Config.Elements as Elements
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Icon exposing (Icon)
import Notification exposing (Notification)
import Route
import Session exposing (Session(..))
import Username
import Viewer



-- MODEL & INIT


type alias Model =
    { notifications : Bool }


initModel : () -> Model
initModel _ =
    { notifications = True }


initCommands : Model -> ( Model, Cmd msg )
initCommands model =
    ( model, Cmd.none )



-- UPDATE


type Msg parentMsg
    = ParentMsg parentMsg
    | ChangedNotificationsSetting Bool


update : Msg pm -> Model -> ( Model, Cmd (Msg pm) )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        ParentMsg _ ->
            ignore

        ChangedNotificationsSetting bool ->
            ( { model | notifications = bool }, Cmd.none )



-- VIEW


view :
    ((Notification.Id -> Notification) -> parentMsg)
    -> Session
    -> Model
    -> Element (Msg parentMsg)
view requestNotification session model =
    column Styles.page
        [ column Styles.content
            [ Input.radioRow [ spacing 20 ]
                { onChange = ChangedNotificationsSetting
                , selected = Just model.notifications
                , label =
                    Input.labelLeft
                        Styles.inputLabel
                        (text "Message Notifications:")
                , options =
                    [ Input.optionWith True <|
                        \state ->
                            Elements.labeledRight "On" <|
                                Icon.view (radioIcon state)
                    , Input.optionWith False <|
                        \state ->
                            Elements.labeledRight "Off" <|
                                Icon.view (radioIcon state)
                    ]
                }
            ]
        , textColumn Styles.content
            [ el
                [ Font.color Colors.fadedInk ]
                (text "• Master Debug Menu •")
            , el
                [ Font.color Colors.fadedInk ]
                (text "« Fire Test Notifications »")
            , Elements.inertLink
                [ Events.onClick <|
                    ParentMsg (requestNotification Notification.passwordsDontMatch)
                ]
                (text "Mismatch passwords")
            , Elements.credentialed session
                { loggedIn =
                    \viewer ->
                        Elements.inertLink
                            [ Events.onClick <|
                                ParentMsg <|
                                    requestNotification <|
                                        Notification.receivedMessage
                                            (Viewer.authToken viewer)
                                            Username.debug
                                            "A little bit of technique in there as well."
                            ]
                            (text "Short message")
                , guest = none
                }
            , Elements.credentialed session
                { loggedIn =
                    \viewer ->
                        Elements.inertLink
                            [ Events.onClick <|
                                ParentMsg <|
                                    requestNotification <|
                                        Notification.receivedMessage
                                            (Viewer.authToken viewer)
                                            Username.debug
                                            "I can double your GP just meet me at the chaos altar"
                            ]
                            (text "Long message")
                , guest = none
                }
            ]
        ]


radioIcon : Input.OptionState -> Icon
radioIcon state =
    case state of
        Input.Idle ->
            Icon.radioOff Icon.Medium

        Input.Focused ->
            Icon.radioFocused Icon.Medium

        Input.Selected ->
            Icon.radioOn Icon.Medium
