module Page.Settings exposing (Model, Msg(..), init, update, view)

import Browser.Navigation as Nav
import Config.Elements as Elements
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Icon
import Notification exposing (Notification)
import Route
import Session exposing (Session(..))
import Username
import Viewer



-- MODEL & INIT


type alias Model =
    { notifications : Bool }


init : ( Model, Cmd msg )
init =
    ( { notifications = True }
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Toggled Notifications ->
            ( { model | notifications = not model.notifications }, Cmd.none )

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
                    "Message Alerts"
                        |> Elements.iconified (Icon.notifications model.notifications Icon.Medium)
                }
            ]
        , textColumn Styles.content
            [ el
                [ Font.color Colors.fadedInk ]
                (text "• Master Debug Menu •")
            , Elements.credentialed session
                { loggedIn =
                    \_ ->
                        link
                            [ Events.onClick (ClickedLogout (Session.navKey session)) ]
                            { url = Route.inert
                            , label = text "Log out"
                            }
                , guest =
                    link
                        [ Events.onClick (ClickedLogin (Session.navKey session)) ]
                        { url = Route.inert
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
                { url = Route.inert
                , label = text "Mismatch passwords"
                }
            , Elements.credentialed session
                { loggedIn =
                    \viewer ->
                        link
                            [ Events.onClick <|
                                RequestedNotification <|
                                    Notification.receivedMessage
                                        (Viewer.authToken viewer)
                                        Username.debug
                                        "A little bit of technique in there as well."
                            ]
                            { url = Route.inert
                            , label = text "Short message"
                            }
                , guest = none
                }
            , Elements.credentialed session
                { loggedIn =
                    \viewer ->
                        link
                            [ Events.onClick <|
                                RequestedNotification <|
                                    Notification.receivedMessage
                                        (Viewer.authToken viewer)
                                        Username.debug
                                        "I can double your GP just meet me at the chaos altar"
                            ]
                            { url = Route.inert
                            , label = text "Long message"
                            }
                , guest = none
                }
            ]
        ]
