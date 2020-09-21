module Page.Settings exposing (Model, Msg(..), init, update, view)

import Alert exposing (Alert)
import Browser.Navigation as Nav
import Config.Layout as Layout
import Config.Styles as Styles
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Icon exposing (Icon)
import Page exposing (Page)
import Route
import Session exposing (Session(..))
import Username
import Viewer



-- MODEL & INIT


type alias Model =
    { alerts : Bool }


init : () -> ( Model, Cmd msg )
init _ =
    ( { alerts = True }, Cmd.none )



-- UPDATE


type Msg parentMsg
    = ParentMsg parentMsg
    | ChangedAlerts Bool


update : Msg pmsg -> Model -> ( Model, Cmd (Msg pmsg) )
update msg model =
    let
        ignore =
            ( model, Cmd.none )
    in
    case msg of
        ParentMsg _ ->
            ignore

        ChangedAlerts bool ->
            ( { model | alerts = bool }, Cmd.none )



-- VIEW


view :
    ((Alert.Id -> Alert) -> pmsg)
    -> Session
    -> Model
    -> Page (Msg pmsg)
view requestAlert session model =
    { navbarItem = Page.Settings
    , title = "User Settings"
    , body =
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
                        \viewer ->
                            Layout.inertLink
                                [ Events.onClick <|
                                    ParentMsg <|
                                        requestAlert <|
                                            Alert.receivedMessage
                                                (Viewer.authToken viewer)
                                                Username.debug
                                                "A little bit of technique in there as well."
                                ]
                                (text "Short message")
                    , guest = none
                    }
                , Layout.credentialed session
                    { loggedIn =
                        \viewer ->
                            Layout.inertLink
                                [ Events.onClick <|
                                    ParentMsg <|
                                        requestAlert <|
                                            Alert.receivedMessage
                                                (Viewer.authToken viewer)
                                                Username.debug
                                                "I can double your GP just meet me at the chaos altar"
                                ]
                                (text "Long message")
                    , guest = none
                    }
                ]
            ]
    }
