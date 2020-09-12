module Main exposing (main)

import Avatar
import Browser exposing (Document, UrlRequest)
import Browser.Events as Events
import Browser.Navigation as Nav
import Config.Links as Links
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Font as Font
import Element.Lazy exposing (..)
import Icon
import Notification exposing (Notification, notify)
import Notification.Queue
import Page.Home
import Page.Search
import Page.Settings
import Route exposing (Route)
import Time
import Ui exposing (DeviceSize, responsive)
import Url exposing (Url)
import Username
import Viewer exposing (Viewer)



-- MODEL & INIT


type alias Model =
    { key : Nav.Key
    , currentRoute : Route
    , viewer : Maybe Viewer
    , deviceSize : DeviceSize
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
            { key = key
            , currentRoute = initialRoute
            , viewer = Just Viewer.debug
            , deviceSize = deviceSize
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
    | NotificationFired Notification
    | NotificationExpired Notification
    | ChangedQuery String
    | ChangedSettings Page.Settings.Msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Events.onResize (\w h -> ResizedDevice (DeviceSize w h)) ]


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
                ( model, Nav.pushUrl model.key (Url.toString url) )

        ClickedLink (Browser.External href) ->
            ( model, Nav.load href )

        ResizedDevice size ->
            ( { model | deviceSize = size }, Cmd.none )

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

        ChangedSettings Page.Settings.LoggedOut ->
            -- Dispatching to Page.Settings is curtailed in this particular case
            ( { model | viewer = Nothing }
            , notify Notification.loggedOut NotificationFired
            )

        ChangedSettings (Page.Settings.LoggedIn viewer) ->
            -- Dispatching to Page.Settings is curtailed in this particular case
            let
                notif =
                    Notification.loggedIn (Viewer.username viewer)
            in
            ( { model | viewer = Just viewer }
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
document ({ currentRoute, deviceSize, viewer, notifications } as model) =
    let
        navbar =
            inFront (lazy2 viewNavbar deviceSize viewer)

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


viewNavbar : DeviceSize -> Maybe Viewer -> Element msg
viewNavbar deviceSize viewer =
    let
        iconSize =
            Icon.size.small

        ( username, avatar, messages ) =
            ( viewer
                |> Maybe.map Viewer.username
                |> Maybe.map Username.toString
                |> Maybe.map ((++) "@")
                |> Maybe.withDefault "Guest"
            , viewer
                |> Maybe.map Viewer.avatar
                |> Maybe.withDefault Avatar.default
            , viewer
                |> Maybe.map Viewer.messages
                |> Maybe.withDefault 0
            )

        linkIfLoggedIn =
            case viewer of
                Just _ ->
                    link

                Nothing ->
                    always (always none)
    in
    row Styles.navbar
        [ link []
            { url = Links.internal.home
            , label =
                row Styles.logo
                    [ image []
                        { src = Links.assets.logo
                        , description = "The " ++ Strings.appName ++ " logo"
                        }
                    , text
                        (responsive deviceSize
                            { compact = Strings.appNameShort
                            , full = Strings.appName
                            }
                        )
                    ]
            }
        , link []
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
                Ui.pill 69 <|
                    Ui.labelRight "Messages" <|
                        Icon.view <|
                            Icon.paperPlane iconSize
            }
        , link []
            { url = Links.internal.tools
            , label =
                Ui.labelRight "Toolbox" <|
                    Icon.view <|
                        Icon.toolbox iconSize
            }

        -- TODO: change to newTabLink with a proper link
        , link [ alignRight ]
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
                Ui.labelRight username <|
                    Avatar.view 24 avatar
            }
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
            lazy2 Page.Settings.view model.viewer model.settings
                |> Element.map ChangedSettings

        _ ->
            none
