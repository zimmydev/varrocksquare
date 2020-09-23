module Page exposing (NavbarItem(..), Page, label, labelIcon, map, pill, spinner, unthemed, view)

{-| This module mostly contains the view rendering that's common to all pages,
e.g. the navbar, the footer, page title, formatting, etc.
-}

import Alert.Queue as Queue exposing (Queue)
import Avatar
import Browser
import Config.App as App
import Config.Assets as Assets
import Config.Strings as Strings
import Config.Styles as Styles
import Device
import Element exposing (..)
import Element.Lazy exposing (..)
import Html
import Html.Attributes
import Icon exposing (Icon)
import LoggedInUser
import Route
import Session exposing (Session)
import Username


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



-- Converting a Page


map : (msg -> pmsg) -> Page msg -> Page pmsg
map parentMsg page =
    { navbarItem = page.navbarItem
    , title = page.title
    , body = Element.map parentMsg page.body
    }


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
                { navbar = lazy3 navbar session devpro page.navbarItem
                , alertArea = lazy Queue.view alerts
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



-- Navbar


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
            [ List.singleton (logo devpro)
            , convert leftLinks
            , convert rightLinks
            ]


logo : Device.Profile -> Element msg
logo devpro =
    let
        logotype =
            Device.responsive devpro
                { compact = Strings.appNameCompact
                , full = Strings.appName
                }
    in
    Route.link []
        { route = Route.Home
        , body =
            row Styles.logo
                [ image []
                    { src = Assets.logo
                    , description = "The " ++ Strings.appName ++ " logo"
                    }
                , text logotype
                ]
        }


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
            Session.credentialed session
                { guest = none
                , loggedIn =
                    Route.link itemStyle
                        { route = Route.NewPost
                        , body =
                            Device.responsive devpro
                                { compact = Icon.view icon
                                , full = labelIcon icon "New Post"
                                }
                        }
                }

        Search ->
            let
                icon =
                    Icon.search iconSize
            in
            Route.link
                itemStyle
                { route = Route.Search Nothing
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = labelIcon icon "Search"
                        }
                }

        Tools ->
            let
                icon =
                    Icon.wrench iconSize
            in
            Route.link
                itemStyle
                { route = Route.Tools
                , body =
                    Device.responsive devpro
                        { compact = Icon.view icon
                        , full = labelIcon icon "Tools"
                        }
                }

        Starred ->
            let
                icon =
                    Icon.starBox iconSize
            in
            Session.credentialed session
                { guest = none
                , loggedIn =
                    Route.link itemStyle
                        { route = Route.Starred
                        , body =
                            Device.responsive devpro
                                { compact = Icon.view icon
                                , full = labelIcon icon "Starred"
                                }
                        }
                }

        Inbox ->
            let
                icon =
                    Icon.paperPlane iconSize
            in
            Session.credentialed session
                { guest = none
                , loggedIn =
                    Route.link itemStyle
                        { route = Route.Inbox
                        , body =
                            Device.responsive devpro
                                { compact = Icon.view icon
                                , full = "Inbox" |> labelIcon icon |> pill 69
                                }
                        }
                }

        Donate ->
            let
                icon =
                    Icon.donate iconSize
            in
            Route.inert (Styles.donate devpro) <|
                Device.responsive devpro
                    { compact = Icon.view icon
                    , full = labelIcon icon "Donate!"
                    }

        Discord ->
            Device.responsive devpro <|
                { compact = none
                , full =
                    Route.external []
                        { target = Route.Discord
                        , body = Icon.view (Icon.discord iconSize)
                        }
                }

        Github ->
            Device.responsive devpro <|
                { compact = none
                , full =
                    Route.external []
                        { target = Route.Github
                        , body = Icon.view (Icon.github iconSize)
                        }
                }

        Help ->
            Route.link []
                { route = Route.Help
                , body = Icon.view (Icon.help iconSize)
                }

        Login ->
            Session.credentialed session
                { loggedIn = none
                , guest =
                    Route.link itemStyle
                        { route = Route.Login
                        , body = text "Login"
                        }
                }

        Register ->
            Session.credentialed session
                { loggedIn = none
                , guest =
                    Route.link itemStyle
                        { route = Route.Register
                        , body = text "Register"
                        }
                }

        Settings ->
            let
                icon =
                    Icon.settings iconSize
            in
            Session.credentialed session
                { guest = none
                , loggedIn =
                    Route.link itemStyle
                        { route = Route.Settings
                        , body =
                            Device.responsive devpro
                                { compact = Icon.view icon
                                , full = labelIcon icon "Settings"
                                }
                        }
                }

        Logout ->
            Session.credentialed session
                { guest = none
                , loggedIn =
                    Route.link itemStyle
                        { route = Route.Logout
                        , body = text "Logout"
                        }
                }

        Profile ->
            Session.withLoggedInUser session
                { guest =
                    Route.link Styles.highlighted
                        { route = Route.Register
                        , body =
                            Avatar.default
                                |> Avatar.view avatarSize
                                |> label "Guest"
                        }
                , loggedIn =
                    \loggedInUser ->
                        let
                            username =
                                LoggedInUser.username loggedInUser
                        in
                        Route.link Styles.highlighted
                            { route = Route.Profile username
                            , body =
                                LoggedInUser.avatar loggedInUser
                                    |> Avatar.view avatarSize
                                    |> label ("@" ++ Username.toString username)
                                    |> el Styles.highlighted
                            }
                }

        Other ->
            Other
                |> App.logProblem "Accidently tried to render an `Other` page" none



-- Footer


footer : Element msg
footer =
    row Styles.footer <|
        List.map (el Styles.footerElement)
            [ credit
            , privacyPolicyLink
            , copyright
            ]


credit : Element msg
credit =
    Route.link [ alignLeft ]
        { route = Route.Profile Username.appAuthor
        , body = text "Made with ♥︎ by Zimmy"
        }


privacyPolicyLink : Element msg
privacyPolicyLink =
    Route.link [ centerX ]
        { route = Route.PrivacyPolicy
        , body = text "Privacy Policy"
        }


copyright : Element msg
copyright =
    Route.external [ alignRight ]
        { target = Route.Company
        , body = text Strings.copyright
        }



-- Exposed Reusable Page Elements


spinner : List (Attribute msg) -> Element msg
spinner attrs =
    let
        emptyDiv =
            Html.div [] []
    in
    el (attrs ++ Styles.spinner) <|
        html <|
            Html.div [ Html.Attributes.class "spinner" ] (List.repeat 4 emptyDiv)


labelIcon : Icon -> String -> Element msg
labelIcon icon lbl =
    Icon.view icon
        |> label lbl


label : String -> Element msg -> Element msg
label lbl element =
    place
        { left = element
        , right = text lbl
        }


pill : Int -> Element msg -> Element msg
pill count element =
    let
        pillNode =
            el Styles.pill <|
                text (String.fromInt count)
    in
    if count > 0 then
        place
            { left = element
            , right = pillNode
            }

    else
        element



-- Helpers


appTitle : String -> String
appTitle pageTitle =
    pageTitle ++ " • " ++ Strings.appName


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


place : { left : Element msg, right : Element msg } -> Element msg
place { left, right } =
    smallSpace [ left, right ]


smallSpace : List (Element msg) -> Element msg
smallSpace children =
    row [ Styles.smallSpacing ] children
