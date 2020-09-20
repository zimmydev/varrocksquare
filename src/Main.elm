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
import Notification exposing (Notification, notify)
import Notification.Queue exposing (Queue)
import Page.Home
import Page.Search
import Page.Settings
import Route exposing (Route)
import Session exposing (Session(..))
import Time
import Url exposing (Url)
import Username
import Viewer



-- MODEL & INIT


type alias Model =
    { session : Session
    , currentRoute : Route
    , deviceProfile : Device.Profile
    , menuIsExtended : Bool
    , notifications : Queue
    , searchQuery : String
    , settings : Page.Settings.Model
    }


init : Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flagsJson url navKey =
    let
        flags =
            Flags.decode flagsJson

        initialRoute =
            Route.routeUrl url

        ( settings, settingsCmd ) =
            Page.Settings.init

        model =
            { session = Session.new navKey (Just Viewer.debug)
            , currentRoute = initialRoute
            , deviceProfile = Device.profile flags.size
            , menuIsExtended = False
            , notifications = Notification.Queue.empty
            , searchQuery = ""
            , settings = settings
            }

        cmd =
            case initialRoute of
                Route.Redirect href ->
                    Route.redirect (Session.navKey model.session) href

                Route.Login ->
                    Route.push navKey Route.Root

                Route.Logout ->
                    Route.push navKey Route.Root

                Route.Search _ ->
                    Cmd.batch
                        [ Page.Search.focusSearchbar Ignored, Cmd.none ]

                _ ->
                    Cmd.none
    in
    ( model, Cmd.batch [ cmd, settingsCmd ] )


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = document
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = Route.routeUrl >> ChangedRoute
        }



-- UPDATE


type Msg
    = Ignored
    | ClickedLink UrlRequest
    | ChangedRoute Route
    | ResizedDevice Device.Profile
    | ClickedNavMenu
    | NotificationFired Notification
    | NotificationExpired Notification
    | ChangedQuery String
    | ChangedSettings Page.Settings.Msg


subscriptions : Model -> Sub Msg
subscriptions { deviceProfile, settings } =
    Sub.batch
        [ Browser.Events.onResize (handleResize deviceProfile) ]


handleResize : Device.Profile -> Int -> Int -> Msg
handleResize oldProfile width height =
    let
        newProfile =
            Device.profile (Device.Size width height)
    in
    if newProfile /= oldProfile then
        ResizedDevice newProfile

    else
        Ignored


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Ignored ->
            ( model, Cmd.none )

        ClickedLink (Browser.Internal url) ->
            let
                nextRoute =
                    Route.routeUrl url
            in
            if nextRoute == model.currentRoute then
                update Ignored model

            else
                ( model, Route.push (Session.navKey model.session) nextRoute )

        ClickedLink (Browser.External href) ->
            ( model, Debug.log "Use `Route.Redirect`!" () |> always Cmd.none )

        ChangedRoute route ->
            let
                routedModel =
                    { model | currentRoute = route }

                navKey =
                    Session.navKey model.session
            in
            case route of
                Route.Redirect href ->
                    ( model, Route.redirect navKey href )

                Route.Login ->
                    let
                        newViewer =
                            Viewer.debug
                    in
                    ( { model | session = Session.new navKey (Just newViewer) }
                    , Cmd.batch
                        [ notify (Notification.loggedIn (Viewer.username newViewer)) NotificationFired
                        , Route.push navKey Route.Root
                        ]
                    )

                Route.Logout ->
                    ( { model | session = Session.new navKey Nothing }
                    , Cmd.batch
                        [ notify Notification.loggedOut NotificationFired
                        , Route.push navKey Route.Root
                        ]
                    )

                Route.Search maybeQuery ->
                    ( routedModel, Page.Search.focusSearchbar Ignored )

                _ ->
                    ( routedModel, Cmd.none )

        ResizedDevice deviceProfile ->
            ( { model | deviceProfile = deviceProfile }, Cmd.none )

        ClickedNavMenu ->
            ( { model | menuIsExtended = not model.menuIsExtended }, Cmd.none )

        NotificationFired notif ->
            ( { model
                | notifications =
                    model.notifications
                        |> Notification.Queue.push model.settings.notifications notif
              }
            , Notification.expire notif NotificationExpired
            )

        NotificationExpired notif ->
            ( { model | notifications = model.notifications |> Notification.Queue.remove notif }
            , Cmd.none
            )

        ChangedQuery query ->
            ( { model | searchQuery = query }, Cmd.none )

        ChangedSettings (Page.Settings.NotificationFired notif) ->
            -- Re-route to NotificationFired event
            model |> update (NotificationFired notif)

        ChangedSettings submsg ->
            let
                ( newSettings, subcmd ) =
                    model.settings |> Page.Settings.update submsg
            in
            ( { model | settings = newSettings }, Cmd.map ChangedSettings subcmd )



-- VIEW


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



-- PAGES


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
            lazy2 Page.Settings.view model.session model.settings
                |> Element.map ChangedSettings

        _ ->
            none
