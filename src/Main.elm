module Main exposing (main)

import Api exposing (AuthToken)
import Avatar
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Nav
import Config.Links as Links exposing (Href)
import Config.Strings as Strings
import Config.Styles as Styles
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
import Ui exposing (DeviceProfile(..))
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
    , searchQuery : Maybe String
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
            Ui.profileDevice deviceSize.width

        ( settings, settingsCmd ) =
            Page.Settings.init

        model =
            { session = Session.new key (Just Viewer.debug)
            , currentRoute = initialRoute
            , deviceProfile = deviceProfile
            , menuIsExtended = False
            , notifications = Notification.Queue.empty
            , searchQuery = Nothing
            , settings = settings
            }

        cmd =
            case initialRoute of
                Route.Search ->
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
    | PerformedShortcut Href
    | ResizedDevice DeviceProfile
    | ClickedMenu
    | NotificationFired Notification
    | NotificationExpired Notification
    | ChangedQuery String
    | ChangedSettings Page.Settings.Msg


subscriptions : Model -> Sub Msg
subscriptions { deviceProfile, settings } =
    Sub.batch
        [ Browser.Events.onResize (handleResize deviceProfile) ]


handleResize : DeviceProfile -> Int -> Int -> Msg
handleResize oldProfile width _ =
    let
        newProfile =
            Ui.profileDevice width
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
                Route.Search ->
                    ( { routedModel | searchQuery = Nothing }
                    , Page.Search.focusSearchbar Ignored
                    )

                _ ->
                    ( routedModel, Cmd.none )

        ClickedLink (Browser.Internal url) ->
            if Route.routeUrl url == model.currentRoute then
                update Ignored model

            else
                ( model, Nav.pushUrl (Session.navKey model.session) (Url.toString url) )

        ClickedLink (Browser.External href) ->
            ( model, Nav.load href )

        PerformedShortcut href ->
            ( model, Nav.pushUrl (Session.navKey model.session) href )

        ResizedDevice deviceProfile ->
            ( { model | deviceProfile = deviceProfile }, Cmd.none )

        ClickedMenu ->
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
            if String.isEmpty query then
                ( { model | searchQuery = Nothing }, Cmd.none )

            else
                ( { model | searchQuery = Just query }, Cmd.none )

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
                    Notification.loggedIn (Username.debug "zimmy")
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
        maybeViewer =
            Session.viewer session

        iconSize =
            Icon.size.small

        ( displayName, avatar ) =
            ( maybeViewer
                |> Maybe.map Viewer.username
                |> Maybe.map Username.toString
                |> Maybe.map ((++) "@")
                |> Maybe.withDefault "Guest"
            , maybeViewer
                |> Maybe.map Viewer.avatar
                |> Maybe.withDefault Avatar.default
            )

        logo =
            List.singleton <|
                link []
                    { url = Links.internal.home
                    , label =
                        row Styles.logo
                            [ image []
                                { src = Links.images.logo
                                , description = "The " ++ Strings.appName ++ " logo"
                                }
                            , text
                                (Ui.responsive deviceProfile
                                    { compact = Strings.appNameShort
                                    , full = Strings.appName
                                    }
                                )
                            ]
                    }

        linkIfLoggedIn attrs linkInfo =
            Ui.credentialed session
                { loggedIn = \_ -> link attrs linkInfo
                , guest = none
                }

        primaryLinks =
            [ link []
                { url = Links.internal.explore
                , label =
                    Ui.label "Explore" <|
                        Icon.view <|
                            Icon.binoculars iconSize
                }
            , link []
                { url = Links.internal.search
                , label =
                    Ui.label "Search" <|
                        Icon.view <|
                            Icon.search iconSize
                }
            , link []
                { url = Links.internal.tools
                , label =
                    Ui.label "Tools" <|
                        Icon.view <|
                            Icon.wrench iconSize
                }
            , linkIfLoggedIn []
                { url = Links.internal.saved
                , label =
                    Ui.label "Saved" <|
                        Icon.view <|
                            Icon.starBox iconSize
                }
            , linkIfLoggedIn []
                { url = Links.internal.messages
                , label =
                    Ui.pill 69 <|
                        Ui.label "Messages" <|
                            Icon.view <|
                                Icon.paperPlane iconSize
                }
            ]

        secondaryLinks =
            [ link [ alignRight ]
                { url = Links.external.donate
                , label =
                    Ui.label "Donate!" <|
                        Icon.view <|
                            Icon.donate iconSize
                }
            , newTabLink []
                { url = Links.external.github
                , label = Icon.view (Icon.github iconSize)
                }
            , newTabLink []
                { url = Links.external.discord
                , label = Icon.view (Icon.discord iconSize)
                }
            , link []
                { url = Links.internal.help
                , label = Icon.view (Icon.help iconSize)
                }
            , link Styles.highlighted
                { url = Links.internal.settings
                , label =
                    Ui.label displayName <|
                        Avatar.view 24 avatar
                }
            ]

        siteMenu =
            case deviceProfile of
                Full ->
                    primaryLinks

                Compact ->
                    List.singleton <|
                        link
                            [ Events.onClick ClickedMenu -- has the convenient side-effect of firing this message when a child is clicked, thereby closing the menu; happens to be the behavior we want!
                            , if menuIsExtended then
                                below <|
                                    column Styles.menu primaryLinks

                              else
                                below none
                            ]
                            { url = Links.internal.inert
                            , label =
                                Ui.label "Menu" <|
                                    Icon.view <|
                                        if menuIsExtended then
                                            Icon.upArrow iconSize

                                        else
                                            Icon.downArrow iconSize
                            }
    in
    row Styles.navbar <|
        List.concat <|
            [ logo
            , siteMenu
            , secondaryLinks
            ]


footer : Element msg
footer =
    row Styles.footer
        [ el Styles.footerLeft (text Strings.credit)
        , el Styles.footerCenter <|
            row
                [ centerX ]
                [ text "Icons by "
                , newTabLink []
                    { url = Links.external.icons8
                    , label = Icon.view (Icon.icons8 Icon.size.small)
                    }
                ]
        , el Styles.footerCenter (text "Privacy Policy")
        , el Styles.footerRight (text Strings.copyright)
        ]



-- PAGES


renderPage : Model -> Element Msg
renderPage model =
    -- Display a page depending on the Route
    case model.currentRoute of
        Route.Home ->
            lazy Page.Home.view ()

        Route.Search ->
            lazy2 Page.Search.view ChangedQuery model.searchQuery

        Route.Settings ->
            lazy2 Page.Settings.view model.session model.settings
                |> Element.map ChangedSettings

        _ ->
            none
