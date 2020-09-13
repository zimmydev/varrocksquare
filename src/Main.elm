module Main exposing (main)

import Avatar
import Browser exposing (Document, UrlRequest)
import Browser.Events
import Browser.Navigation as Nav
import Config.Links as Links
import Config.Strings as Strings
import Config.Styles as Styles
import Credentials exposing (Credentials)
import Element exposing (..)
import Element.Events as Events
import Element.Font as Font
import Element.Lazy exposing (..)
import Icon
import Inbox
import Notification exposing (Notification, notify)
import Notification.Queue
import Page.Home
import Page.Search
import Page.Settings
import Route exposing (Route)
import Session exposing (Session(..))
import Time
import Ui exposing (DeviceSize)
import Url exposing (Url)
import Username



-- MODEL & INIT


type alias Model =
    { session : Session
    , currentRoute : Route
    , deviceSize : DeviceSize
    , menuIsExtended : Bool
    , notifications : Notification.Queue.Queue
    , searchQuery : Maybe String
    , settings : Page.Settings.Model
    }


type alias Flags =
    DeviceSize


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init deviceSize url key =
    let
        initialRoute =
            Route.routeUrl url

        ( settings, settingsCmd ) =
            Page.Settings.init

        model =
            { session = Session.debug key
            , currentRoute = initialRoute
            , deviceSize = deviceSize
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
    | ResizedDevice DeviceSize
    | ClickedMenu
    | NotificationFired Notification
    | NotificationExpired Notification
    | ChangedQuery String
    | ChangedSettings Page.Settings.Msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize (\w h -> ResizedDevice (DeviceSize w h)) ]


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

        ResizedDevice size ->
            ( { model | deviceSize = size }, Cmd.none )

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
            ( { model | session = Guest key }
            , notify Notification.loggedOut NotificationFired
            )

        ChangedSettings (Page.Settings.ClickedLogin key) ->
            -- Dispatching to Page.Settings is curtailed in this particular case
            let
                notif =
                    Notification.loggedIn (Username.debug "zimmy")
            in
            ( { model | session = Session.debug key }
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
document ({ currentRoute, deviceSize, menuIsExtended, session, notifications } as model) =
    let
        navbar =
            inFront (lazy3 viewNavbar session deviceSize menuIsExtended)

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


viewNavbar : Session -> DeviceSize -> Bool -> Element Msg
viewNavbar session deviceSize menuIsExtended =
    let
        iconSize =
            Icon.size.small

        ( displayName, avatar, messageCount ) =
            ( Session.displayName session
            , Session.avatar session
            , session
                |> Session.inbox
                |> Maybe.map Inbox.messageCount
                |> Maybe.withDefault 0
            )

        logo =
            link []
                { url = Links.internal.home
                , label =
                    row Styles.logo
                        [ image []
                            { src = Links.assets.logo
                            , description = "The " ++ Strings.appName ++ " logo"
                            }
                        , text
                            (Ui.responsive deviceSize
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
                    Ui.labelRight "Explore" <|
                        Icon.view <|
                            Icon.binoculars iconSize
                }
            , link []
                { url = Links.internal.search
                , label =
                    Ui.labelRight "Search" <|
                        Icon.view <|
                            Icon.search iconSize
                }
            , link []
                { url = Links.internal.tools
                , label =
                    Ui.labelRight "Tools" <|
                        Icon.view <|
                            Icon.wrench iconSize
                }
            , linkIfLoggedIn []
                { url = Links.internal.saved
                , label =
                    Ui.labelRight "Saved" <|
                        Icon.view <|
                            Icon.starBox iconSize
                }
            , linkIfLoggedIn []
                { url = Links.internal.messages
                , label =
                    Ui.pill messageCount <|
                        Ui.labelRight "Messages" <|
                            Icon.view <|
                                Icon.paperPlane iconSize
                }
            ]

        secondaryLinks =
            [ link [ alignRight ]
                { url = Links.external.donate
                , label =
                    Ui.labelRight "Donate!" <|
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
                    Ui.labelRight displayName <|
                        Avatar.view 24 avatar
                }
            ]
    in
    row Styles.navbar <|
        List.concat <|
            [ List.singleton logo
            , if Ui.isCompact deviceSize then
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
                            Ui.labelRight "Menu" <|
                                Icon.view <|
                                    if menuIsExtended then
                                        Icon.upArrow iconSize

                                    else
                                        Icon.downArrow iconSize
                        }

              else
                primaryLinks
            , secondaryLinks
            ]


footer : Element msg
footer =
    row Styles.footer
        [ el Styles.footerCenter (text Strings.credit)
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
        , el Styles.footerCenter (text Strings.copyright)
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
