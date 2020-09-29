module Page.Redirect exposing (State, init, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)
import Url


type alias State =
    { href : String }


type alias Href =
    String



-- Init


init : Href -> State
init href =
    { href = href }



-- Views


view : State -> Page msg
view { href } =
    { navbarItem = Page.Other
    , title = activity href
    , body = lazy body href
    }


body : Href -> Element msg
body href =
    el Styles.seguePage <|
        el Styles.segueContent <|
            text (activity href)



-- Helpers


activity : Href -> String
activity href =
    href
        |> Url.fromString
        |> Maybe.map .host
        |> Maybe.map
            (\host ->
                "Redirecting to " ++ host ++ "…"
            )
        |> Maybe.withDefault "Redirecting…"
