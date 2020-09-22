module Page exposing (NavbarItem(..), Page, map, unthemed, view)

{-| This module mostly contains the view rendering that's common to all pages,
e.g. the navbar, the footer, page title, formatting, etc.
-}

import Alert.Queue as Queue exposing (Queue)
import Avatar
import Browser
import Config.App as App
import Config.Layout as Layout exposing (iconified, label, pill)
import Config.Strings as Strings
import Config.Styles as Styles
import Device
import Element exposing (..)
import Element.Lazy exposing (..)
import Icon
import Route
import Session exposing (Session)
import Username exposing (Username)
import Viewer



-- TYPES


type alias Page msg =
    { title : String
    , navbarItem : NavbarItem
    , body : Element msg
    }


type
    NavbarItem
    -- Left
    = NewPost
    | Search
    | Tools
    | Starred
    | Inbox
      -- Right
    | Donate
    | Discord
    | Github
    | Help
    | Login
    | Register
    | Settings
    | Logout
    | Profile
      -- Other
    | Other



-- TOP-LEVEL VIEW


view : Session -> Device.Profile -> Queue -> Page msg -> Browser.Document msg
view session devpro alerts page =
    toHtmlDocument <|
        { title = appTitle page.title
        , body =
            column
                [ width fill, height fill ]
                [ row
                    [ width fill ]
                    [ el [ width (fillPortion 1) ] none
                    , page.body
                    , el [ width (fillPortion 1) ] none
                    ]
                , lazy (always footer) ()
                ]
        , style = Styles.root
        , focus = Styles.focus
        , hud =
            Just
                { navbar = navbar session devpro page.navbarItem
                , alertArea = Queue.view alerts
                }
        }


unthemed : Page msg -> Browser.Document msg
unthemed page =
    toHtmlDocument <|
        { title = appTitle page.title
        , body = page.body
        , style = []
        , focus = Styles.focus
        , hud = Nothing
        }



-- NAVBAR


navbar : Session -> Device.Profile -> NavbarItem -> Element msg
navbar session devpro activeItem =
    let
        convert items =
            items
                |> List.map navbarItem
                |> List.map (\f -> f session devpro activeItem)

        leftLinks =
            [ NewPost
            , Search
            , Tools
            , Starred
            , Inbox
            ]

        rightLinks =
            [ Donate
            , Discord
            , Github
            , Help
            , Login
            , Register
            , Settings
            , Logout
            , Profile
            ]
    in
    row (Styles.navbar devpro) <|
        List.concat <|
            [ List.singleton (Layout.logo devpro)
            , convert leftLinks
            , convert rightLinks
            ]


navbarItem : NavbarItem -> Session -> Device.Profile -> NavbarItem -> Element msg
navbarItem item session devpro activeItem =
    let
        iconSize =
            Device.responsive devpro
                { compact = Icon.Medium
                , full = Icon.Small
                }

        avatarSize =
            Device.responsive devpro
                { compact = 32
                , full = 26
                }

        itemStyle =
            Styles.navbarItem (item == activeItem)
    in
    case item of
        NewPost ->
            let
                icon =
                    Icon.pencil iconSize
            in
            Layout.credentialedLink session
                itemStyle
                { route = Route.NewPost
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = iconified icon "New Post"
                        }
                }

        Search ->
            let
                icon =
                    Icon.search iconSize
            in
            Layout.link
                itemStyle
                { route = Route.Search Nothing
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = iconified icon "Search"
                        }
                }

        Tools ->
            let
                icon =
                    Icon.wrench iconSize
            in
            Layout.link
                itemStyle
                { route = Route.Tools
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = iconified icon "Tools"
                        }
                }

        Starred ->
            let
                icon =
                    Icon.starBox iconSize
            in
            Layout.credentialedLink session
                itemStyle
                { route = Route.Starred
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = iconified icon "Starred"
                        }
                }

        Inbox ->
            let
                icon =
                    Icon.paperPlane iconSize
            in
            Layout.credentialedLink session
                itemStyle
                { route = Route.Inbox
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full =
                            "Inbox" |> iconified icon |> pill 69
                        }
                }

        Donate ->
            let
                icon =
                    Icon.donate iconSize
            in
            Layout.inertLink (Styles.donate devpro) <|
                Device.responsive devpro
                    { compact = Icon.view icon
                    , full = iconified icon "Donate!"
                    }

        Discord ->
            Layout.fullscreenOrNone devpro <|
                Layout.externalLink []
                    { href = Route.discord
                    , body = Icon.view (Icon.discord iconSize)
                    }

        Github ->
            Layout.fullscreenOrNone devpro <|
                Layout.externalLink []
                    { href = Route.github
                    , body = Icon.view (Icon.github iconSize)
                    }

        Help ->
            Layout.link []
                { route = Route.Help
                , body = Icon.view (Icon.help iconSize)
                }

        Login ->
            Layout.guestLink session
                itemStyle
                { route = Route.Login
                , body = text "Login"
                }

        Register ->
            Layout.guestLink session
                itemStyle
                { route = Route.Register
                , body = text "Register"
                }

        Settings ->
            let
                icon =
                    Icon.settings iconSize
            in
            Layout.credentialedLink session
                itemStyle
                { route = Route.Settings
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = iconified icon "Settings"
                        }
                }

        Logout ->
            Layout.credentialedLink session
                itemStyle
                { route = Route.Logout
                , body = text "Logout"
                }

        Profile ->
            Layout.credentialed session
                { guest =
                    Layout.link Styles.highlighted
                        { route = Route.Register
                        , body =
                            Avatar.default
                                |> Avatar.view avatarSize
                                |> Layout.label "Guest"
                        }
                , loggedIn =
                    \viewer ->
                        let
                            username =
                                Viewer.username viewer
                        in
                        Layout.link Styles.highlighted
                            { route = Route.Profile username
                            , body =
                                Viewer.avatar viewer
                                    |> Avatar.view avatarSize
                                    |> label ("@" ++ Username.toString username)
                                    |> el Styles.highlighted
                            }
                }

        Other ->
            Other
                |> App.logProblem "Accidently tried to render an `Other` page" none



-- FOOTER


footer : Element msg
footer =
    row Styles.footer <|
        List.map (el Styles.footerElement)
            [ Layout.credit
            , Layout.privacyPolicyLink
            , Layout.copyright
            ]



-- HELPERS


appTitle : String -> String
appTitle pageTitle =
    pageTitle ++ " • " ++ Strings.appName



-- PAGE RENDERING


map : (msg -> pmsg) -> Page msg -> Page pmsg
map parentMsg page =
    { navbarItem = page.navbarItem
    , title = page.title
    , body = Element.map parentMsg page.body
    }


toHtmlDocument :
    { title : String
    , body : Element msg
    , style : List (Attribute msg)
    , focus : FocusStyle
    , hud :
        Maybe
            { navbar : Element msg
            , alertArea : Element msg
            }
    }
    -> Browser.Document msg
toHtmlDocument config =
    let
        layoutBody =
            case config.hud of
                Just hud ->
                    layoutWith { options = [ focusStyle config.focus ] }
                        (inFront hud.navbar :: inFront hud.alertArea :: config.style)

                Nothing ->
                    layout config.style
    in
    { title = config.title
    , body = List.singleton <| layoutBody config.body
    }
