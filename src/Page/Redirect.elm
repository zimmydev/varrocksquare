module Page.Redirect exposing (view)

import Config.Styles as Styles
import Element exposing (..)
import Page exposing (Page)


view : () -> Page msg
view () =
    { navbarItem = Page.Other
    , title = "Redirecting…"
    , body =
        el Styles.redirectPage <|
            el [ centerX, centerY ] <|
                text "Redirecting…"
    }
