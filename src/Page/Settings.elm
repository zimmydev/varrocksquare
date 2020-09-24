module Page.Settings exposing (Effect(..), Msg(..), init, update, view)

import Alert exposing (Alert)
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (..)
import Icon
import LoggedInUser
import Page exposing (Page)
import Route
import Session exposing (Session(..))
import Settings exposing (Settings)
import Username



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
    | ChangedAlerts Bool



-- Effects


type Effect
    = NoEffect



-- Init


init : () -> ( Settings, Cmd msg )
init _ =
    ( Settings.default
    , Cmd.none
    )



-- Update


update : Msg pmsg -> Settings -> ( Settings, Effect )
update msg settings =
    let
        ignore =
            ( settings, NoEffect )
    in
    case msg of
        ParentMsg _ ->
            ignore

        ChangedAlerts bool ->
            ( { settings | alerts = bool }, NoEffect )



-- Views


view :
    ((Alert.Id -> Alert) -> parentMsg)
    -> Session
    -> Settings
    -> Page (Msg parentMsg)
view requestAlert session settings =
    { navbarItem = Page.Settings
    , title = "User Settings"
    , body = lazy3 body requestAlert session settings
    }


body : ((Alert.Id -> Alert) -> parentMsg) -> Session -> Settings -> Element (Msg parentMsg)
body requestAlert session settings =
    column Styles.page
        [ el Styles.content <|
            Input.radioRow [ spacing 20 ]
                { onChange = ChangedAlerts
                , selected = Just settings.alerts
                , label =
                    Input.labelLeft
                        Styles.inputLabel
                        (text "Message Notifications:")
                , options =
                    [ Input.optionWith True <|
                        \state ->
                            Page.label "On" <|
                                Icon.view (Icon.radio state Icon.Medium)
                    , Input.optionWith False <|
                        \state ->
                            Page.label "Off" <|
                                Icon.view (Icon.radio state Icon.Medium)
                    ]
                }
        , textColumn Styles.content
            [ el
                [ Font.color Colors.fadedInk ]
                (text "• Master Debug Menu •")
            , el
                [ Font.color Colors.fadedInk ]
                (text "« Fire Test Notifications »")
            , Route.inert
                [ Events.onClick <|
                    ParentMsg (requestAlert Alert.passwordsDontMatch)
                ]
                (text "Mismatch passwords")
            , Session.withLoggedInUser session
                { loggedIn =
                    \loggedInUser ->
                        Route.inert
                            [ Events.onClick <|
                                ParentMsg <|
                                    requestAlert <|
                                        Alert.receivedMessage
                                            loggedInUser
                                            Username.debug
                                            "A little bit of technique in there as well."
                            ]
                            (text "Short message")
                , guest = none
                }
            , Session.withLoggedInUser session
                { loggedIn =
                    \loggedInUser ->
                        Route.inert
                            [ Events.onClick <|
                                ParentMsg <|
                                    requestAlert <|
                                        Alert.receivedMessage
                                            loggedInUser
                                            Username.debug
                                            "I can double your GP just meet me at the chaos altar"
                            ]
                            (text "Long message")
                , guest = none
                }
            ]
        ]
