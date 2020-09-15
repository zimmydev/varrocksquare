module Main exposing (main)

import Api exposing (AuthToken)
import Avatar
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Nav
import Config.Elements as Elements exposing (iconified, labeledRight, pill)
import Config.ExternalHref as ExternalHref
import Config.Strings as Strings
import Config.Styles as Styles
import DeviceProfile exposing (DeviceProfile(..), DeviceSize)
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Lazy exposing (..)
import Icon
import Inbox
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
    , deviceProfile : DeviceProfile
    , menuIsExtended : Bool
    , notifications : Queue
    , searchQuery : String
    , settings : Page.Settings.Model
    }


type alias Flags =
    { width : Int, height : Int }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init deviceSize url key =
    let
        initialRoute =
            Route.routeUrl url

        deviceProfile =
            DeviceProfile.profile deviceSize

        ( settings, settingsCmd ) =
            Page.Settings.init

        model =
            { session = Session.new key (Just Viewer.debug)
            , currentRoute = initialRoute
            , deviceProfile = deviceProfile
            , menuIsExtended = False
            , notifications = Notification.Queue.empty
            , searchQuery = ""
            , settings = settings
            }

        cmd =
            case initialRoute of
                Route.Search _ ->
                    Cmd.batch
                        [ Page.Search.focusSearchbar Ignored, Cmd.none ]

                _ ->
                    Cmd.none
    in
    ( model, Cmd.batch [ cmd, settingsCmd ] )


main : Program Flags Model Msg
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
    | ResizedDevice DeviceProfile
    | ClickedNavbarMenu
    | NotificationFired Notification
    | NotificationExpired Notification
    | ChangedQuery String
    | ChangedSettings Page.Settings.Msg


subscriptions : Model -> Sub Msg
subscriptions { deviceProfile, settings } =
    Sub.batch
        [ Browser.Events.onResize (handleResize deviceProfile) ]


handleResize : DeviceProfile -> Int -> Int -> Msg
handleResize oldProfile width height =
    let
        newProfile =
            DeviceProfile.profile (DeviceSize width height)
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

        ChangedRoute route ->
            let
                routedModel =
                    { model | currentRoute = route }
            in
            case route of
                Route.Search maybeQuery ->
                    ( routedModel, Page.Search.focusSearchbar Ignored )

                _ ->
                    ( routedModel, Cmd.none )

        ClickedLink (Browser.Internal url) ->
            if Route.routeUrl url == model.currentRoute then
                update Ignored model

            else
                ( model, Nav.pushUrl (Session.navKey model.session) (Url.toString url) )

        ClickedLink (Browser.External href) ->
            ( model, Nav.load href )

        ResizedDevice deviceProfile ->
            ( { model | deviceProfile = deviceProfile }, Cmd.none )

        ClickedNavbarMenu ->
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

        ChangedSettings (Page.Settings.ClickedLogout key) ->
            -- Dispatching to Page.Settings is curtailed in this particular case
            -- TODO: Clear out the session from the localStorage
            ( { model | session = Session.new key Nothing }
            , notify Notification.loggedOut NotificationFired
            )

        ChangedSettings (Page.Settings.ClickedLogin key) ->
            -- Dispatching to Page.Settings is curtailed in this particular case
            let
                notif =
                    Notification.loggedIn Username.debug
            in
            ( { model | session = Session.new key (Just Viewer.debug) }
            , notify notif NotificationFired
            )

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


viewNavbar : Session -> DeviceProfile -> Bool -> Element Msg
viewNavbar session deviceProfile menuIsExtended =
    let
        sizes =
            { avatar = 24
            , icons = Icon.Small
            }

        linkIfLoggedIn attrs config =
            Elements.credentialed session
                { loggedIn = \_ -> Elements.link attrs config
                , guest = none
                }

        newTabLinkIfFullscreen attrs config =
            DeviceProfile.responsive deviceProfile
                { compact = none
                , full = newTabLink attrs config
                }

        primaryLinks =
            [ Elements.link []
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
            [ newTabLink [ alignRight ]
                { url = ExternalHref.donate
                , label = "Donate" |> iconified (Icon.donate sizes.icons)
                }
            , newTabLinkIfFullscreen []
                { url = ExternalHref.discord
                , label = Icon.discord sizes.icons |> Icon.view
                }
            , newTabLinkIfFullscreen []
                { url = ExternalHref.github
                , label = Icon.github sizes.icons |> Icon.view
                }
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
                    link
                        [ Events.onClick ClickedNavbarMenu
                        , if menuIsExtended then
                            below <|
                                column Styles.menu primaryLinks

                          else
                            below none
                        ]
                        { url = Route.inert
                        , label = "Menu" |> iconified (Icon.arrow menuIsExtended sizes.icons)
                        }
            in
            DeviceProfile.responsive deviceProfile
                { compact = List.singleton dropDown
                , full = primaryLinks
                }
    in
    row Styles.navbar <|
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
