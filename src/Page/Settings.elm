module Page.Settings exposing (Effect(..), Msg(..), State, init, update, view)

import Alert exposing (Alert)
import Config.Assets as Assets
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (..)
import LoggedInUser
import Page exposing (Page)
import Route
import Session exposing (Session(..))
import Settings exposing (Settings)
import Username



-- Model


type alias State =
    { settings : Settings }



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
    | ChangedAlerts Bool



-- Effects


type Effect
    = NoEffect



-- Init


init : Settings -> ( State, Effect )
init settings =
    ( { settings = settings }
    , NoEffect
    )



-- Update


update : Msg parentMsg -> State -> ( State, Effect )
update msg state =
    let
        ignore =
            ( state, NoEffect )

        settings =
            state.settings
    in
    case msg of
        ParentMsg _ ->
            ignore

        ChangedAlerts bool ->
            ( { state | settings = { settings | alerts = bool } }, NoEffect )



-- Views


view :
    ((Alert.Id -> Alert) -> parentMsg)
    -> Session
    -> State
    -> Page (Msg parentMsg)
view requestAlert session state =
    { navbarItem = Page.Settings
    , title = "User Settings"
    , body = lazy3 body requestAlert session state.settings
    }


body : ((Alert.Id -> Alert) -> parentMsg) -> Session -> Settings -> Element (Msg parentMsg)
body requestAlert session settings =
    column Styles.page
        [ el Styles.content <|
            Input.radioRow Styles.radioRow
                { onChange = ChangedAlerts
                , selected = Just settings.alerts
                , label =
                    Input.labelLeft
                        Styles.inputLabel
                        (text "Message Notifications:")
                , options =
                    [ Input.optionWith True <| \state -> Page.label "On" <| Assets.radio state
                    , Input.optionWith False <| \state -> Page.label "Off" <| Assets.radio state
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
            , case session of
                Guest ->
                    none

                LoggedIn loggedInUser ->
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
            , case session of
                Guest ->
                    none

                LoggedIn loggedInUser ->
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
            ]
        ]
