module Page.Settings exposing (Model, Msg(..), init, update, view)

import Browser.Navigation as Nav
import Config.Links as Links
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Icon
import Notification exposing (Notification)
import Session exposing (Session(..))
import Ui
import Username



-- MODEL & INIT


type alias Model =
    { notifications : Bool
    , shortcuts : Bool
    }


init : ( Model, Cmd msg )
init =
    ( { notifications = True
      , shortcuts = True
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = RequestedNotification (Notification.Id -> Notification)
    | NotificationFired Notification
    | ClickedLogin Nav.Key
    | ClickedLogout Nav.Key
    | Toggled SettingsToggle


type SettingsToggle
    = Notifications
    | Shortcuts


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggled Notifications ->
            ( { model | notifications = not model.notifications }, Cmd.none )

        Toggled Shortcuts ->
            ( { model | shortcuts = not model.shortcuts }, Cmd.none )

        RequestedNotification notif ->
            ( model, Notification.notify notif NotificationFired )

        _ ->
            -- Other actions delegated to the Main module
            ( model, Cmd.none )



-- VIEW


view : Session -> Model -> Element Msg
view session model =
    column Styles.page
        [ row [ spacing 24 ]
            [ Input.button (Styles.toggleButton model.notifications)
                { onPress = Just (Toggled Notifications)
                , label =
                    Ui.label "Message Alerts" <|
                        Icon.view <|
                            Icon.notifications model.notifications Icon.size.medium
                }
            , Input.button (Styles.toggleButton model.shortcuts)
                { onPress = Just (Toggled Shortcuts)
                , label =
                    Ui.label "Shortcuts" <|
                        Icon.view <|
                            Icon.shortcuts model.shortcuts Icon.size.medium
                }
            ]
        , textColumn Styles.content
            [ el
                [ Font.color Colors.fadedInk ]
                (text "• Master Debug Menu •")
            , Ui.credentialed session
                { loggedIn =
                    \_ ->
                        link
                            [ Events.onClick (ClickedLogout (Session.navKey session)) ]
                            { url = Links.internal.inert
                            , label = text "Log out"
                            }
                , guest =
                    link
                        [ Events.onClick (ClickedLogin (Session.navKey session)) ]
                        { url = Links.internal.inert
                        , label = text "Log in"
                        }
                }
            , el
                [ Font.color Colors.fadedInk ]
                (text "« Fire Test Notifications »")
            , link
                [ Events.onClick <|
                    RequestedNotification Notification.passwordsDontMatch
                ]
                { url = Links.internal.inert
                , label = text "Mismatch passwords"
                }
            , Ui.credentialed session
                { loggedIn =
                    \cred ->
                        link
                            [ Events.onClick <|
                                RequestedNotification <|
                                    Notification.receivedMessage
                                        cred
                                        (Username.debug "bonecrusher69")
                                        "A little bit of technique"
                            ]
                            { url = Links.internal.inert
                            , label = text "Short message"
                            }
                , guest = none
                }
            , Ui.credentialed session
                { loggedIn =
                    \cred ->
                        link
                            [ Events.onClick <|
                                RequestedNotification <|
                                    Notification.receivedMessage
                                        cred
                                        (Username.debug "Jingle Bells")
                                        "I can double your GP just meet me at the chaos altar"
                            ]
                            { url = Links.internal.inert
                            , label = text "Long message"
                            }
                , guest = none
                }
            ]
        ]
