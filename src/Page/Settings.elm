module Page.Settings exposing (Model, Msg(..), init, update, view)

import Config.Links as Links
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Notification exposing (Notification)
import Username
import Viewer exposing (Viewer)



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
    | LoggedIn Viewer
    | LoggedOut
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


view : Maybe Viewer -> Model -> Element Msg
view maybeViewer model =
    column Styles.page
        [ textColumn Styles.content
            [ el
                [ Font.color Colors.fadedInk ]
                (text "• Master Debug Menu •")
            , link
                [ Events.onClick LoggedOut ]
                { url = Links.internal.inert
                , label = text "Log out"
                }
            , link
                [ Events.onClick (LoggedIn Viewer.debug) ]
                { url = Links.internal.inert
                , label = text "Log in"
                }
            , el
                [ Font.color Colors.fadedInk ]
                (text "– Fire Test Notifications –")
            , link
                [ Events.onClick <|
                    RequestedNotification Notification.passwordsDontMatch
                ]
                { url = Links.internal.inert
                , label = text "Mismatch passwords"
                }
            , case maybeViewer of
                Just viewer ->
                    link
                        [ Events.onClick <|
                            RequestedNotification <|
                                Notification.receivedMessage
                                    (Username.debug "bonecrusher69")
                                    "A little bit of technique"
                                    viewer
                        ]
                        { url = Links.internal.inert
                        , label = text "Short message"
                        }

                Nothing ->
                    none
            , case maybeViewer of
                Just viewer ->
                    link
                        [ Events.onClick <|
                            RequestedNotification <|
                                Notification.receivedMessage
                                    (Username.debug "Jingle Bells")
                                    "I can double your GP just meet me at the chaos altar"
                                    viewer
                        ]
                        { url = Links.internal.inert
                        , label = text "Long message"
                        }

                Nothing ->
                    none
            , case maybeViewer of
                Just viewer ->
                    link
                        [ Events.onClick <|
                            RequestedNotification <|
                                Notification.receivedLink
                                    (Username.debug "Sportball")
                                    "Why EHP is Bullshit"
                                    "http://example.com"
                                    viewer
                        ]
                        { url = Links.internal.inert
                        , label = text "Post share"
                        }

                Nothing ->
                    none
            , el
                [ Font.color Colors.fadedInk ]
                (text "– Toggles –")
            , link
                [ Events.onClick (Toggled Notifications)
                ]
                { url = Links.internal.inert
                , label =
                    text <|
                        "Toggle message notifications (currently "
                            ++ (if model.notifications then
                                    "on"

                                else
                                    "off"
                               )
                            ++ ")"
                }
            , link
                [ Events.onClick (Toggled Shortcuts) ]
                { url = Links.internal.inert
                , label =
                    text <|
                        "Toggle shortcuts (currently "
                            ++ (if model.shortcuts then
                                    "on"

                                else
                                    "off"
                               )
                            ++ ")"
                }
            ]
        ]
