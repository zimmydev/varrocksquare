module Main exposing (Model)

import Api exposing (AuthToken)
import Avatar
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Nav
import Config.Elements as Elements exposing (iconified, labeledRight, pill)
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
import Page.Home
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
    , currentRoute : Route
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
        , onUrlChange = ChangedRoute << Route.routeUrl
        , view = document
        }


init : Value -> Url -> Nav.Key -> ( Model, List Command )
init json url navKey =
    let
        flags =
            Flags.decode json

        initialRoute =
            Route.routeUrl url

        settings =
            Page.Settings.initModel ()

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
            , currentRoute = initialRoute
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
            if nextRoute == model.currentRoute then
                ignore

            else
                ( model, [ PushRoute navKey nextRoute ] )

        ClickedLink (Browser.External href) ->
            -- Use internal `/external?href=…` link redirection mechanism
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
                        { model | currentRoute = nextRoute }
                        [ FocusSearchbar ]

                _ ->
                    ( { model | currentRoute = nextRoute }, [] )

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


document : Model -> Document Msg
document ({ currentRoute, deviceProfile, menuIsExtended, session, notifications } as model) =
    let
        navbar =
            inFront (lazy3 viewNavbar session deviceProfile menuIsExtended)

        notificationArea =
            inFront (lazy Notification.Queue.view notifications)
    in
    { title = Route.title currentRoute
    , body =
        List.singleton <|
            case currentRoute of
                Route.Redirect _ ->
                    layout [] <|
                        el Styles.redirect <|
                            text "Redirecting…"

                _ ->
                    layoutWith
                        { options = [ focusStyle Styles.focus ] }
                        (navbar :: notificationArea :: Styles.root)
                        (column [ width fill, height fill ]
                            [ row [ width fill ]
                                [ el Styles.pageMargin none
                                , lazy renderPage model
                                , el Styles.pageMargin none
                                ]
                            , lazy (always footer) ()
                            ]
                        )
    }


viewNavbar : Session -> Device.Profile -> Bool -> Element Msg
viewNavbar session deviceProfile menuIsExtended =
    let
        sizes =
            { avatar = 26
            , icons =
                Device.responsive deviceProfile
                    { compact = Icon.Medium
                    , full = Icon.Small
                    }
            }

        linkIfLoggedIn attrs config =
            Elements.credentialed session
                { loggedIn = \_ -> Elements.link attrs config
                , guest = none
                }

        ifFullscreen element =
            Device.responsive deviceProfile
                { compact = none
                , full = element
                }

        primaryLinks =
            [ linkIfLoggedIn []
                { route = Route.NewPost
                , label = "New Post" |> iconified (Icon.pencil sizes.icons)
                }
            , Elements.link []
                { route = Route.Search Nothing
                , label = "Search" |> iconified (Icon.search sizes.icons)
                }
            , Elements.link []
                { route = Route.Tools
                , label = "Tools" |> iconified (Icon.wrench sizes.icons)
                }
            , linkIfLoggedIn []
                { route = Route.Starred
                , label = "Starred" |> iconified (Icon.starBox sizes.icons)
                }
            , linkIfLoggedIn []
                { route = Route.Inbox
                , label =
                    "Inbox"
                        |> iconified (Icon.paperPlane sizes.icons)
                        |> pill 69
                }
            ]

        secondaryLinks =
            [ Elements.donateLink deviceProfile sizes.icons
            , ifFullscreen (Elements.discordLink sizes.icons)
            , ifFullscreen (Elements.githubLink sizes.icons)
            , Elements.link []
                { route = Route.Help
                , label = Icon.help sizes.icons |> Icon.view
                }
            , Elements.credentialed session
                { loggedIn =
                    \viewer ->
                        let
                            username =
                                Viewer.username viewer
                        in
                        row [ Styles.navbarSpacing ]
                            [ Elements.link []
                                { route = Route.Settings
                                , label =
                                    "Settings"
                                        |> iconified (Icon.settings sizes.icons)
                                }
                            , Elements.link []
                                { route = Route.Logout
                                , label = text "Logout"
                                }
                            , Elements.link Styles.highlighted
                                { route = Route.Profile username
                                , label =
                                    Viewer.avatar viewer
                                        |> Avatar.view sizes.avatar
                                        |> labeledRight ("@" ++ Username.toString username)
                                }
                            ]
                , guest =
                    row [ Styles.navbarSpacing ]
                        [ Elements.link []
                            { route = Route.Login
                            , label = text "Login"
                            }
                        , Elements.link []
                            { route = Route.Register
                            , label = text "Register"
                            }
                        , Elements.link Styles.highlighted
                            { route = Route.Register
                            , label =
                                Avatar.default
                                    |> Avatar.view sizes.avatar
                                    |> labeledRight "Guest"
                            }
                        ]
                }
            ]

        menuElements =
            let
                dropDown =
                    Elements.inertLink
                        [ Events.onClick ClickedNavMenu
                        , if menuIsExtended then
                            below <|
                                column Styles.menu primaryLinks

                          else
                            below none
                        ]
                        ("Go to…" |> iconified (Icon.arrow menuIsExtended sizes.icons))
            in
            Device.responsive deviceProfile
                { compact = List.singleton dropDown
                , full = primaryLinks
                }
    in
    row (Styles.navbar deviceProfile) <|
        List.concat <|
            [ List.singleton (Elements.logo deviceProfile)
            , menuElements
            , secondaryLinks
            ]


footer : Element msg
footer =
    row Styles.footer <|
        List.map (el Styles.footerElement)
            [ Elements.credit
            , Elements.iconsCredit
            , Elements.privacyPolicyLink
            , Elements.copyright
            ]


renderPage : Model -> Element Msg
renderPage model =
    -- Display a page depending on the Route
    case model.currentRoute of
        Route.Home ->
            lazy Page.Home.view ()

        Route.Search maybeQuery ->
            --(maybeQuery |> Maybe.withDefault model.searchQuery)
            lazy2 Page.Search.view ChangedQuery model.searchQuery

        Route.Settings ->
            lazy3 Page.Settings.view NotificationRequested model.session model.settings
                |> Element.map SettingsMsg

        _ ->
            none



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
