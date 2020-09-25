module Route exposing (ExternalLink(..), Href, Route(..), external, inert, link, push, replace, routeUrl, toHref)

import Browser.Navigation as Nav
import Element exposing (Attribute, Element)
import Post.Slug as Slug exposing (Slug)
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, s)
import Url.Parser.Query as Query
import Username exposing (Username)


{-| `Route` represents the current routing of the application. Routes as a concept are related to
pages, but not 1:1.

Some notes about app-specific routing:

  - `Root` and `Home` will normally be identical routes, but are split into two variants in the
    case that we want to move our `Home` route to make room for e.g. an announcement on the
    frontpage/root route.
  - `Home` is where personal and global feeds are presented.
  - `NotFound` is always the fallback route when no other route can be parsed.

-}
type Route
    = Redirect Href
    | NotFound
      -- Main routes
    | Home
    | Feeds
    | Search (Maybe String)
    | Tools
    | Post Slug
    | Profile Username
    | Help
    | PrivacyPolicy
      -- Main routes (Must be logged-in)
    | NewPost
    | EditPost Slug
    | Settings
    | Starred
    | Inbox
      -- Account actions
    | Login
    | Logout
    | Register


type alias Href =
    String


type ExternalLink
    = Company
    | Donate
    | Github
    | Discord



-- Links


link : List (Attribute msg) -> { route : Route, body : Element msg } -> Element msg
link attrs { route, body } =
    Element.link attrs
        { url = toHref route, label = body }


inert : List (Attribute msg) -> Element msg -> Element msg
inert attrs body =
    Element.link attrs
        { url = Builder.relative [] [], label = body }


external : List (Attribute msg) -> { target : ExternalLink, body : Element msg } -> Element msg
external attrs { target, body } =
    let
        ( root, paths, queries ) =
            case target of
                Company ->
                    ( "https://github.com", [ "zimmydev" ], [] )

                Donate ->
                    ( "http://example.com", [], [] )

                Github ->
                    ( "https://github.com", [ "zimmydev", "varrocksquare" ], [] )

                Discord ->
                    ( "https://discord.gg", [ "jq3gaCS" ], [] )

        redirectionLink =
            Builder.crossOrigin root paths queries
                |> Redirect
                |> toHref
    in
    Element.newTabLink attrs
        { url = redirectionLink, label = body }



-- Routing


parser : Parser (Route -> a) a
parser =
    let
        requireQuery toMsg =
            Maybe.map toMsg >> Maybe.withDefault NotFound
    in
    Parser.oneOf
        [ -- Main routes
          Parser.map Home Parser.top
        , Parser.map Feeds (s "feeds")
        , Parser.map Search (s "search" <?> Query.string "query")
        , Parser.map Tools (s "tools")
        , Parser.map Post (s "post" </> Slug.urlParser)
        , Parser.map Profile (s "profile" </> Username.urlParser)
        , Parser.map (requireQuery Redirect) (s "redirect" <?> Query.string "href")

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


routeUrl : Url -> Route
routeUrl url =
    url
        |> Parser.parse parser
        |> Maybe.withDefault NotFound



-- Commands


push : Nav.Key -> Route -> Cmd msg
push key route =
    Nav.pushUrl key (toHref route)


replace : Nav.Key -> Route -> Cmd msg
replace key route =
    Nav.replaceUrl key (toHref route)



-- De-Routing


toHref : Route -> Href
toHref route =
    let
        ( paths, queries ) =
            case route of
                NotFound ->
                    ( [], [] )

                Home ->
                    ( [], [] )

                Feeds ->
                    ( [ "feeds" ], [] )

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

                Post slug ->
                    ( [ "post", Slug.toString slug ], [] )

                Profile username ->
                    ( [ "profile", Username.toString username ], [] )

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
                    ( [ "redirect" ], [ Builder.string "href" href ] )
    in
    Builder.absolute paths queries
