module Page.Error exposing (State, init, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)


type alias State =
    { reason : String }


type alias Href =
    String



-- Init


init : String -> State
init reason =
    { reason = reason }



-- Views


view : State -> Page msg
view { reason } =
    { navbarItem = Page.Other
    , title = "App Error"
    , body = lazy body reason
    }


body : String -> Element msg
body reason =
    el Styles.seguePage <|
        column Styles.segueContent <|
            [ el [ centerX ] <| text "Whoops! There was a fatal application error:"
            , el Styles.error <| text reason
            ]
