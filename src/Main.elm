module Main exposing (Model)

import Alert exposing (Alert, fire)
import Alert.Queue as Queue exposing (Queue)
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Nav
import Config.App as App
import Device
import Element exposing (..)
import Json.Encode exposing (Value)
import LoggedInUser
import Main.Flags as Flags
import Page
import Page.Home
import Page.NotFound
import Page.Redirect
import Page.Search
import Page.Settings
import Process
import Route exposing (Href, Route)
import Session exposing (Session(..))
import Task
import Url exposing (Url)



-- Model


type alias Model =
    { session : Session
    , route : Route
    , devpro : Device.Profile
    , alerts : Queue
    , searchQuery : String
    , settings : Page.Settings.Model
    }



-- Messages


type Msg
    = Ignored
    | EffectDelayed Effect
    | LoadingTimedOut -- Display a loading spinner… (should be roughly 200-600ms)
    | LinkClicked UrlRequest
    | RouteChanged Route
    | ResizedDevice Device.Profile
    | AlertRequested (Alert.Id -> Alert)
    | AlertFired Alert
    | AlertExpired Alert
    | QueryChanged String
    | SettingsMessaged (Page.Settings.Msg Msg)



-- Effects


type Effect
    = NoEffect
    | Effects (List Effect)
    | DelayEffect Float Effect
    | DelayMsg Float Msg
    | PushRoute Route
    | ReplaceRoute Route
    | Redirect Href
    | FocusSearchbar
    | FireAlert (Alert.Id -> Alert)
    | ExpireAlert Alert
    | SettingsEffect Page.Settings.Effect



-- Main, Subscriptions & Init


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
        , onUrlRequest = LinkClicked
        , onUrlChange = RouteChanged << Route.routeUrl
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

        alwaysEffects =
            DelayMsg 350 LoadingTimedOut

        effects =
            case initialRoute of
                Route.NotFound ->
                    Route.NotFound
                        |> App.logProblem "Initial route not found" (DelayEffect 3000 (PushRoute Route.Root))

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
    [ effects, alwaysEffects ]
        |> Effects
        |> Tuple.pair
            { session = Session.new navKey (Just LoggedInUser.debug)
            , route = initialRoute
            , devpro = Device.profile flags.size
            , alerts = Queue.empty
            , searchQuery = ""
            , settings = settings
            }



-- Update


update : Msg -> Model -> ( Model, Effect )
update msg model =
    let
        ignore =
            ( model, NoEffect )

        navKey =
            Session.navKey model.session
    in
    case msg |> App.logMsg [ Ignored ] of
        Ignored ->
            ignore

        EffectDelayed effect ->
            ( model, effect )

        LoadingTimedOut ->
            -- TODO: Write loading spinner logic.
            ignore

        LinkClicked (Browser.Internal url) ->
            let
                nextRoute =
                    Route.routeUrl url
            in
            if nextRoute == model.route then
                ignore

            else
                ( model, PushRoute nextRoute )

        LinkClicked (Browser.External href) ->
            Browser.External href
                |> App.logProblem "External link accidently embedded in the page (NOTE: Use the app's link redirection mechanism)" ignore

        RouteChanged nextRoute ->
            case nextRoute of
                Route.NotFound ->
                    ( model, DelayEffect 3000 (PushRoute Route.Root) )

                Route.Redirect href ->
                    ( model, Redirect href )

                Route.Login ->
                    let
                        newLoggedInUser =
                            LoggedInUser.debug

                        username =
                            LoggedInUser.username newLoggedInUser
                    in
                    ( { model | session = Session.new navKey (Just newLoggedInUser) }
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
                    ( { model
                        | route = nextRoute
                        , searchQuery = Maybe.withDefault "" maybeQuery
                      }
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

        QueryChanged query ->
            ( { model | searchQuery = query }, NoEffect )

        SettingsMessaged (Page.Settings.ParentMsg myMsg) ->
            update myMsg model

        SettingsMessaged submsg ->
            let
                ( newSettings, effect ) =
                    Page.Settings.update submsg model.settings
            in
            ( { model | settings = newSettings }, SettingsEffect effect )



-- Views


view : Model -> Document Msg
view ({ session, devpro, alerts } as model) =
    let
        viewPage =
            Page.view session devpro alerts
    in
    case model.route of
        Route.NotFound ->
            Page.NotFound.view
                |> Page.unthemed

        Route.Redirect href ->
            Page.Redirect.view href
                |> Page.unthemed

        Route.Home ->
            Page.Home.view ()
                |> viewPage

        Route.Search _ ->
            Page.Search.view QueryChanged model.searchQuery
                |> viewPage

        Route.Settings ->
            Page.Settings.view AlertRequested model.session model.settings
                |> Page.map SettingsMessaged
                |> viewPage

        _ ->
            Page.Home.view ()
                |> viewPage



-- Performing Effects


perform : Nav.Key -> Effect -> Cmd Msg
perform navKey effect =
    case effect |> App.logEffect [ NoEffect, SettingsEffect Page.Settings.NoEffect ] of
        NoEffect ->
            Cmd.none

        Effects effects ->
            Cmd.batch <|
                List.map (perform navKey) effects

        DelayMsg delay msg ->
            Process.sleep delay
                |> Task.perform (always msg)

        DelayEffect delay delayedEffect ->
            Process.sleep delay
                |> Task.perform (\_ -> EffectDelayed delayedEffect)

        PushRoute route ->
            Route.push navKey route

        ReplaceRoute route ->
            Route.replace navKey route

        Redirect href ->
            Nav.load href

        FocusSearchbar ->
            Page.Search.focusSearchbar Ignored

        FireAlert alert ->
            Alert.fire AlertFired alert

        ExpireAlert alert ->
            Alert.expire 5000 AlertExpired alert

        SettingsEffect Page.Settings.NoEffect ->
            Cmd.none
