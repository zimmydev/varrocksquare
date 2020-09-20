module Route exposing (Href, Route(..), api, companyWebsite, discord, donate, github, icons8, push, redirect, replace, routeUrl, title, toHref)

import Browser.Navigation as Nav
import Config.Strings as Strings
import Post.Slug as Slug exposing (Slug)
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, s)
import Url.Parser.Query as Query
import Username exposing (Username)



-- TYPES


{-| `Route` represents the current routing of the application. Routes as a
concept are related to pages, but not 1:1.

Some notes about app-specific routing:

  - `Root` and `Home` will normally be identical routes, but are split into two
    variants in the case that we want to move our `Home` route to make room for
    e.g. an announcement on the frontpage/root route.
  - `Home` is where personal and global feeds are presented.
  - `NotFound` is always the fallback route when no other route can be parsed.

-}
type Route
    = NotFound
      -- Main routes
    | Root
    | Home
    | Post Slug
    | Profile Username
    | Search (Maybe String)
    | Tools
    | Help
    | PrivacyPolicy
      -- Main routes (credentialed)
    | NewPost
    | EditPost Slug
    | Settings
    | Starred
    | Inbox
      -- Account actions
    | Login
    | Logout
    | Register
      -- Redirection
    | Redirect Href


type alias Href =
    String



-- URLS


companyWebsite : Href
companyWebsite =
    -- TODO: Establish a better company website link
    Builder.crossOrigin "https://github.com/zimmydev" [] []


github : Href
github =
    Builder.crossOrigin "https://github.com" [ "zimmydev", "varrocksquare" ] []


discord : Href
discord =
    Builder.crossOrigin "https://discord.gg" [ "jq3gaCS" ] []


donate : Href
donate =
    -- TODO: Currently intert; establish a donation link
    Builder.crossOrigin "http://example.com" [] []


icons8 : Href
icons8 =
    Builder.crossOrigin "https://icons8.com" [] []



-- URL HELPERS


top : Href
top =
    Builder.absolute [] []



-- ROUTE PARSING


parser : Parser (Route -> a) a
parser =
    let
        requireQuery toMsg =
            Maybe.map toMsg >> Maybe.withDefault NotFound
    in
    Parser.oneOf
        [ -- Main routes
          Parser.map Home Parser.top
        , Parser.map Post (s "post" </> Slug.urlParser)
        , Parser.map Profile (s "profile" </> Username.urlParser)
        , Parser.map Search (s "search" <?> Query.string "query")
        , Parser.map Tools (s "tools")
        , Parser.map (requireQuery Redirect) (s "link" <?> Query.string "href")

        -- Main routes (credentialed)
        , Parser.map NewPost (s "editor")
        , Parser.map EditPost (s "editor" </> Slug.urlParser)
        , Parser.map Settings (s "settings")
        , Parser.map Starred (s "starred")
        , Parser.map Inbox (s "inbox")

        -- Account actions
        , Parser.map Login (s "login")
        , Parser.map Logout (s "logout")
        , Parser.map Register (s "register")

        -- Low-traffic main routes
        , Parser.map Help (s "help")
        , Parser.map PrivacyPolicy (s "privacy-policy")
        ]



-- ROUTING


routeUrl : Url -> Route
routeUrl url =
    url
        |> Parser.parse parser
        |> Maybe.withDefault NotFound



-- ROUTING COMMANDS


redirect : Nav.Key -> Href -> Cmd msg
redirect key href =
    Nav.load (Debug.log "A redirect is required to" href)


push : Nav.Key -> Route -> Cmd msg
push key route =
    Nav.pushUrl key (toHref route)


replace : Nav.Key -> Route -> Cmd msg
replace key route =
    Nav.replaceUrl key (toHref route)



-- DEROUTING


toHref : Route -> Href
toHref route =
    let
        ( paths, queries ) =
            case route of
                NotFound ->
                    ( [], [] )

                Root ->
                    ( [], [] )

                Home ->
                    ( [], [] )

                Post slug ->
                    ( [ "post", Slug.toString slug ], [] )

                Profile username ->
                    ( [ "profile", Username.toString username ], [] )

                Search maybeQuery ->
                    ( [ "search" ]
                    , case maybeQuery of
                        Nothing ->
                            []

                        Just query ->
                            [ Builder.string "query" query ]
                    )

                Tools ->
                    ( [ "tools" ], [] )

                Help ->
                    ( [ "help" ], [] )

                PrivacyPolicy ->
                    ( [ "privacy-policy" ], [] )

                NewPost ->
                    ( [ "editor" ], [] )

                EditPost slug ->
                    ( [ "editor", Slug.toString slug ], [] )

                Settings ->
                    ( [ "settings" ], [] )

                Starred ->
                    ( [ "starred" ], [] )

                Inbox ->
                    ( [ "inbox" ], [] )

                Login ->
                    ( [ "login" ], [] )

                Logout ->
                    ( [ "logout" ], [] )

                Register ->
                    ( [ "register" ], [] )

                Redirect href ->
                    ( [ "link" ], [ Builder.string "href" href ] )
    in
    Builder.absolute paths queries



-- PUBLIC INFO


title : Route -> String
title route =
    let
        prefixAppName s =
            Strings.appName ++ " • " ++ s
    in
    case route of
        -- Main routes
        Root ->
            title Home

        Home ->
            prefixAppName Strings.appTagline

        Post _ ->
            prefixAppName "Post"

        Profile username ->
            prefixAppName (Username.toPossessiveString username ++ " Profile")

        Search Nothing ->
            prefixAppName "Search"

        Search (Just query) ->
            prefixAppName ("Search for '" ++ query ++ "'")

        Tools ->
            prefixAppName "Tools for F2P"

        Help ->
            prefixAppName "Help"

        PrivacyPolicy ->
            prefixAppName "Privacy Policy"

        -- Main routes (credentialed)
        NewPost ->
            prefixAppName "New Post"

        EditPost _ ->
            prefixAppName "Editing Post"

        Settings ->
            prefixAppName "Settings"

        Starred ->
            prefixAppName "Starred Posts"

        Inbox ->
            prefixAppName "Inbox"

        -- Account actions
        Login ->
            prefixAppName "Login"

        Logout ->
            prefixAppName "Logging out…"

        Register ->
            prefixAppName "Registration"

        NotFound ->
            prefixAppName "Page not found!"

        Redirect href ->
            "Redirecting…"



-- API


api =
    { login =
        apiRoute [ "login" ] []
    , posts =
        \maybeSort ->
            case maybeSort of
                Just sortType ->
                    apiRoute [ "posts" ] [ Builder.string "sort" sortType ]

                Nothing ->
                    apiRoute [ "posts" ] []
    }



-- API HELPERS


apiRoute : List String -> List Builder.QueryParameter -> Href
apiRoute path =
    Builder.absolute ("api" :: path)
