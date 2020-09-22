module Page.Settings exposing (Effect(..), Model, Msg(..), init, update, view)

import Alert exposing (Alert)
import Browser.Navigation as Nav
import Config.Layout as Layout
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (..)
import Icon exposing (Icon)
import Page exposing (Page)
import Route
import Session exposing (Session(..))
import Username
import LoggedInUser



-- MODEL


type alias Model =
    { alerts : Bool }



-- MSG


type Msg parentMsg
    = ParentMsg parentMsg
    | ChangedAlerts Bool



-- EFFECTS


type Effect
    = NoEffect



-- INIT


init : () -> ( Model, Cmd msg )
init _ =
    ( { alerts = True }, Cmd.none )



-- UPDATE


update : Msg pmsg -> Model -> ( Model, Effect )
update msg model =
    let
        ignore =
            ( model, NoEffect )
    in
    case msg of
        ParentMsg m ->
            ignore

        ChangedAlerts bool ->
            ( { model | alerts = bool }, NoEffect )



-- VIEWS


view :
    ((Alert.Id -> Alert) -> parentMsg)
    -> Session
    -> Model
    -> Page (Msg parentMsg)
view requestAlert session model =
    { navbarItem = Page.Settings
    , title = "User Settings"
    , body = lazy3 body requestAlert session model
    }


body : ((Alert.Id -> Alert) -> parentMsg) -> Session -> Model -> Element (Msg parentMsg)
body requestAlert session model =
    column Styles.page
        [ el Styles.content <|
            Input.radioRow [ spacing 20 ]
                { onChange = ChangedAlerts
                , selected = Just model.alerts
                , label =
                    Input.labelLeft
                        Styles.inputLabel
                        (text "Message Notifications:")
                , options =
                    [ Input.optionWith True <|
                        \state ->
                            Layout.label "On" <|
                                Icon.view (Icon.radio state Icon.Medium)
                    , Input.optionWith False <|
                        \state ->
                            Layout.label "Off" <|
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
            , Layout.inertLink
                [ Events.onClick <|
                    ParentMsg (requestAlert Alert.passwordsDontMatch)
                ]
                (text "Mismatch passwords")
            , Layout.credentialed session
                { loggedIn =
                    \loggedInUser ->
                        Layout.inertLink
                            [ Events.onClick <|
                                ParentMsg <|
                                    requestAlert <|
                                        Alert.receivedMessage
                                            (LoggedInUser.authToken loggedInUser)
                                            Username.debug
                                            "A little bit of technique in there as well."
                            ]
                            (text "Short message")
                , guest = none
                }
            , Layout.credentialed session
                { loggedIn =
                    \loggedInUser ->
                        Layout.inertLink
                            [ Events.onClick <|
                                ParentMsg <|
                                    requestAlert <|
                                        Alert.receivedMessage
                                            (LoggedInUser.authToken loggedInUser)
                                            Username.debug
                                            "I can double your GP just meet me at the chaos altar"
                            ]
                            (text "Long message")
                , guest = none
                }
            ]
        ]
