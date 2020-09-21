module Main exposing (Model)

import Alert exposing (Alert, fire)
import Alert.Queue as Queue exposing (Queue)
import Api exposing (AuthToken)
import Avatar
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Nav
import Config.Layout as Layout exposing (iconified, label, pill)
import Config.Strings as Strings
import Config.Styles as Styles
import Device
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Lazy exposing (..)
import Icon
import Inbox
import Json.Encode exposing (Value)
import Main.Flags as Flags
import Page
import Page.Home
import Page.Redirect
import Page.Search
import Page.Settings
import Route exposing (Href, Route)
import Session exposing (Session(..))
import Time
import Url exposing (Url)
import Username
import Viewer



-- MODEL


type alias Model =
    { session : Session
    , route : Route
    , devpro : Device.Profile
    , alerts : Queue
    , searchQuery : String
    , settings : Page.Settings.Model
    }



-- MESSAGES & EFFECTS


type Msg
    = Ignored
    | ClickedLink UrlRequest
    | ChangedRoute Route
    | ResizedDevice Device.Profile
    | AlertRequested (Alert.Id -> Alert)
    | AlertFired Alert
    | AlertExpired Alert
    | ChangedQuery String
    | SettingsMsg (Page.Settings.Msg Msg)


type Effect
    = NoEffect
    | Effects (List Effect)
    | PushRoute Route
    | ReplaceRoute Route
    | Redirect Href
    | FocusSearchbar
    | FireAlert (Alert.Id -> Alert)
    | ExpireAlert Alert
    | SettingsCommand (Cmd (Page.Settings.Msg Msg))



-- MAIN & INIT


main : Program Value Model Msg
main =
    let
        performEffect ( model, effect ) =
            let
                navKey =
                    Session.navKey model.session
            in
            ( model, perform navKey effect )
    in
    Browser.application
        { init = \json url key -> init json url key |> performEffect
        , subscriptions = subscriptions
        , update = \msg model -> update msg model |> performEffect
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedRoute << Route.routeUrl
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onResize <|
            Device.resizeHandler model.devpro
                { resized = ResizedDevice
                , noOp = Ignored
                }
        ]


init : Value -> Url -> Nav.Key -> ( Model, Effect )
init json url navKey =
    let
        flags =
            Flags.decode json

        initialRoute =
            Route.routeUrl url

        ( settings, settingsCmd ) =
            Page.Settings.init ()

        commands =
            case initialRoute of
                Route.Redirect href ->
                    -- Redirect works on fresh page load and on re-route
                    Redirect href

                Route.Logout ->
                    -- Not supposed to load fresh on this page, redirect to root
                    PushRoute Route.Root

                Route.Search _ ->
                    FocusSearchbar

                _ ->
                    NoEffect
    in
    commands
        |> Tuple.pair
            { session = Session.new navKey (Just Viewer.debug)
            , route = initialRoute
            , devpro = Device.profile flags.size
            , alerts = Queue.empty
            , searchQuery = ""
            , settings = settings
            }



-- UPDATE


update : Msg -> Model -> ( Model, Effect )
update msg model =
    let
        ignore =
            ( model, NoEffect )

        navKey =
            Session.navKey model.session
    in
    case msg of
        Ignored ->
            ignore

        ClickedLink (Browser.Internal url) ->
            let
                nextRoute =
                    Route.routeUrl url
            in
            if nextRoute == model.route then
                ignore

            else
                ( model, PushRoute nextRoute )

        ClickedLink (Browser.External href) ->
            -- NOTE: Use internal `/link?href=…` external link redirection mechanism
            ignore

        ChangedRoute nextRoute ->
            case nextRoute of
                Route.Redirect href ->
                    ( model, Redirect href )

                Route.Login ->
                    let
                        newViewer =
                            Viewer.debug

                        username =
                            Viewer.username newViewer
                    in
                    ( { model | session = Session.new navKey (Just newViewer) }
                    , Effects
                        [ FireAlert (Alert.loggedIn username)
                        , PushRoute (Route.Profile username)
                        ]
                    )

                Route.Logout ->
                    ( { model | session = Session.new navKey Nothing }
                    , Effects
                        [ FireAlert Alert.loggedOut
                        , PushRoute Route.Root
                        ]
                    )

                Route.Search maybeQuery ->
                    ( { model | route = nextRoute }
                    , FocusSearchbar
                    )

                _ ->
                    ( { model | route = nextRoute }, NoEffect )

        ResizedDevice devpro ->
            ( { model | devpro = devpro }, NoEffect )

        AlertRequested alert ->
            ( model, FireAlert alert )

        AlertFired alert ->
            let
                allowed =
                    model.settings.alerts
                        || not (Alert.canSilence alert)

                nextQueue =
                    if allowed then
                        model.alerts |> Queue.push alert

                    else
                        model.alerts
            in
            ( { model | alerts = nextQueue }, ExpireAlert alert )

        AlertExpired alert ->
            ( { model | alerts = model.alerts |> Queue.remove alert }, NoEffect )

        ChangedQuery query ->
            ( { model | searchQuery = query }, NoEffect )

        -- SETTINGS
        SettingsMsg (Page.Settings.ParentMsg myMsg) ->
            update myMsg model

        SettingsMsg submsg ->
            let
                ( newSettings, subcmd ) =
                    Page.Settings.update submsg model.settings
            in
            ( { model | settings = newSettings }, SettingsCommand subcmd )



-- VIEWS


view : Model -> Document Msg
view ({ session, devpro, alerts } as model) =
    let
        viewPage =
            Page.view session devpro alerts
    in
    case model.route of
        Route.Redirect _ ->
            Page.Redirect.view ()
                |> Page.unthemed

        Route.Home ->
            Page.Home.view ()
                |> viewPage

        Route.Search _ ->
            Page.Search.view ChangedQuery model.searchQuery
                |> viewPage

        Route.Settings ->
            Page.Settings.view AlertRequested model.session model.settings
                |> Page.map SettingsMsg
                |> viewPage

        _ ->
            Page.Home.view ()
                |> viewPage



-- PERFORMING EFFECTS


perform : Nav.Key -> Effect -> Cmd Msg
perform navKey effect =
    case effect of
        NoEffect ->
            Cmd.none

        Effects effects ->
            Cmd.batch <|
                List.map (perform navKey) effects

        PushRoute route ->
            Route.push navKey route

        ReplaceRoute route ->
            Route.replace navKey route

        Redirect href ->
            Route.redirect navKey href

        FocusSearchbar ->
            Page.Search.focusSearchbar Ignored

        FireAlert alert ->
            Alert.fire AlertFired alert

        ExpireAlert alert ->
            Alert.expire AlertExpired alert

        SettingsCommand cmd ->
            Cmd.map SettingsMsg cmd
