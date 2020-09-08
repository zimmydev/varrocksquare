module Route exposing (Route(..), routeUrl, title)

import Config.Strings as Strings
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>))
import Url.Parser.Query as Query


type Route
    = Home
    | Explore
    | Search
    | Saved
    | Messages
    | Tools
    | Help
    | Profile String
    | Settings
    | NotFound


type alias GroupId =
    String


routeUrl : Url -> Route
routeUrl url =
    let
        requireQuery route maybeRoute =
            maybeRoute
                |> Maybe.map route
                |> Maybe.withDefault NotFound

        routeParsers =
            [ Parser.map Home Parser.top
            , Parser.map Explore (Parser.s "explore")
            , Parser.map Search (Parser.s "search")
            , Parser.map Saved (Parser.s "saved")
            , Parser.map Messages (Parser.s "messages")
            , Parser.map Tools (Parser.s "tools")
            , Parser.map Help (Parser.s "help")
            , Parser.map (requireQuery Profile) (Parser.s "profile" <?> Query.string "user")
            , Parser.map Settings (Parser.s "settings")
            ]
    in
    url
        |> Parser.parse (Parser.oneOf routeParsers)
        |> Maybe.withDefault NotFound


title : Route -> String
title route =
    let
        t =
            case route of
                Home ->
                    Strings.titles.home

                Explore ->
                    Strings.titles.explore

                Search ->
                    Strings.titles.search

                Saved ->
                    Strings.titles.saved

                Messages ->
                    Strings.titles.messages

                Tools ->
                    Strings.titles.tools

                Help ->
                    Strings.titles.help

                Profile username ->
                    Strings.titles.profileFor username

                Settings ->
                    Strings.titles.settings

                NotFound ->
                    Strings.titles.pageNotFound
    in
    String.join " " [ Strings.appName, "•", t ]
