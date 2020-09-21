module Page.Redirect exposing (view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)
import Url



-- TYPES


type alias Href =
    String



-- VIEWS


view : Href -> Page msg
view href =
    let
        redirecting =
            redirectingString href
    in
    { navbarItem = Page.Other
    , title = redirecting
    , body = lazy body redirecting
    }


body : String -> Element msg
body label =
    el Styles.redirectPage <|
        el [ centerX, centerY ] <|
            text label


redirectingString : Href -> String
redirectingString href =
    href
        |> Url.fromString
        |> Maybe.map .host
        |> Maybe.map
            (\host ->
                "Redirecting to " ++ host ++ "…"
            )
        |> Maybe.withDefault "Redirecting…"
