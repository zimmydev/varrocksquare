module Main exposing (Model)

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
import Notification exposing (Notification, fire)
import Notification.Queue exposing (Queue)
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
    , deviceProfile : Device.Profile
    , menuIsExtended : Bool
    , notifications : Queue
    , searchQuery : String
    , settings : Page.Settings.Model
    }



-- MESSAGES, COMMANDS & SUBSCRIPTIONS


type Msg
    = Ignored
    | ClickedLink UrlRequest
    | ChangedRoute Route
    | ResizedDevice Device.Profile
    | NotificationRequested (Notification.Id -> Notification)
    | NotificationFired Notification
    | NotificationExpired Notification
    | ClickedNavMenu
    | ChangedQuery String
    | SettingsMsg (Page.Settings.Msg Msg)


type Command
    = PushRoute Nav.Key Route
    | ReplaceRoute Nav.Key Route
    | Redirect Nav.Key Href
    | FocusSearchbar
    | FireNotification (Notification.Id -> Notification)
    | ExpireNotification Notification
    | SettingsCommand (Cmd (Page.Settings.Msg Msg))


type Subscription
    = BrowserResize (Device.ResizeHandler Msg)



-- MAIN & INIT


main : Program Value Model Msg
main =
    let
        subscriptions model =
            [ BrowserResize <|
                Device.resizeHandler model.deviceProfile
                    { resized = ResizedDevice
                    , noOp = Ignored
                    }
            ]
    in
    Browser.application
        { init =
            \json url key ->
                Tuple.mapSecond toCmd <|
                    init json url key
        , subscriptions = subscriptions >> toSub
        , update =
            \msg model ->
                Tuple.mapSecond toCmd <|
                    update msg model
        , onUrlRequest = ClickedLink
        , onUrlChange = Route.routeUrl >> ChangedRoute
        , view = view
        }


init : Value -> Url -> Nav.Key -> ( Model, List Command )
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
                    [ Redirect navKey href ]

                Route.Login ->
                    -- Not supposed to load fresh on this page, redirect to root
                    [ PushRoute navKey Route.Root ]

                Route.Logout ->
                    -- Not supposed to load fresh on this page, redirect to root
                    [ PushRoute navKey Route.Root ]

                Route.Search _ ->
                    [ FocusSearchbar ]

                _ ->
                    []
    in
    commands
        |> Tuple.pair
            { session = Session.new navKey (Just Viewer.debug)
            , route = initialRoute
            , deviceProfile = Device.profile flags.size
            , menuIsExtended = False
            , notifications = Notification.Queue.empty
            , searchQuery = ""
            , settings = settings
            }



-- UPDATE


update : Msg -> Model -> ( Model, List Command )
update msg model =
    let
        ignore =
            ( model, [] )

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
                ( model, [ PushRoute navKey nextRoute ] )

        ClickedLink (Browser.External href) ->
            -- NOTE: Use internal `/link?href=…` link redirection mechanism
            ignore

        ChangedRoute nextRoute ->
            case nextRoute of
                Route.Redirect href ->
                    ( model, [ Redirect navKey href ] )

                Route.Login ->
                    let
                        newViewer =
                            Viewer.debug

                        username =
                            Viewer.username newViewer
                    in
                    Tuple.pair
                        { model | session = Session.new navKey (Just newViewer) }
                        [ FireNotification (Notification.loggedIn username)
                        , PushRoute navKey (Route.Profile username)
                        ]

                Route.Logout ->
                    Tuple.pair
                        { model | session = Session.new navKey Nothing }
                        [ FireNotification Notification.loggedOut
                        , PushRoute navKey Route.Root
                        ]

                Route.Search maybeQuery ->
                    Tuple.pair
                        { model | route = nextRoute }
                        [ FocusSearchbar ]

                _ ->
                    ( { model | route = nextRoute }, [] )

        ResizedDevice deviceProfile ->
            ( { model | deviceProfile = deviceProfile }, [] )

        NotificationRequested notif ->
            ( model, [ FireNotification notif ] )

        NotificationFired notif ->
            let
                allowed =
                    model.settings.notifications
                        || not (Notification.canSilence notif)

                nextQueue =
                    if allowed then
                        model.notifications
                            |> Notification.Queue.push notif

                    else
                        model.notifications
            in
            Tuple.pair
                { model | notifications = nextQueue }
                [ ExpireNotification notif ]

        NotificationExpired notif ->
            Tuple.pair
                { model
                    | notifications =
                        model.notifications
                            |> Notification.Queue.remove notif
                }
                []

        ClickedNavMenu ->
            Tuple.pair
                { model | menuIsExtended = not model.menuIsExtended }
                []

        ChangedQuery query ->
            Tuple.pair
                { model | searchQuery = query }
                []

        -- SETTINGS
        SettingsMsg (Page.Settings.ParentMsg myMsg) ->
            update myMsg model

        SettingsMsg submsg ->
            let
                ( newSettings, subcmd ) =
                    Page.Settings.update submsg model.settings
            in
            ( { model | settings = newSettings }, [ SettingsCommand subcmd ] )



-- VIEWS


view : Model -> Document Msg
view model =
    let
        viewPage =
            Page.view model.session model.deviceProfile model.notifications
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
            Page.Settings.view NotificationRequested model.session model.settings
                |> Page.map SettingsMsg
                |> viewPage

        _ ->
            Page.Home.view ()
                |> viewPage



-- COMMAND AND SUBSCRIPTION MAPPINGS


toCmd : List Command -> Cmd Msg
toCmd commands =
    let
        convert c =
            case c of
                PushRoute navKey route ->
                    Route.push navKey route

                ReplaceRoute navKey route ->
                    Route.replace navKey route

                Redirect navKey href ->
                    Route.redirect navKey href

                FocusSearchbar ->
                    Page.Search.focusSearchbar Ignored

                FireNotification notif ->
                    Notification.fire NotificationFired notif

                ExpireNotification notif ->
                    Notification.expire NotificationExpired notif

                SettingsCommand cmd ->
                    Cmd.map SettingsMsg cmd
    in
    Cmd.batch <|
        List.map convert commands


toSub : List Subscription -> Sub Msg
toSub subs =
    let
        convert s =
            case s of
                BrowserResize toMsg ->
                    Browser.Events.onResize toMsg
    in
    subs
        |> List.map convert
        |> Sub.batch
