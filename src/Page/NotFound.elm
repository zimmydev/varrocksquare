module Page.NotFound exposing (view)

import Config.Assets as Assets
import Config.Layout as Layout
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)
import Route



-- VIEWS


view : Page msg
view =
    { navbarItem = Page.Other
    , title = "Page not found!"
    , body = lazy (always body) ()
    }


body : Element msg
body =
    el Styles.seguePage <|
        column [ centerX, centerY, spacing 30 ] <|
            [ Layout.link [ centerX ] <|
                { route = Route.Root
                , body =
                    image []
                        { src = Assets.notFoundImage
                        , description = "Page not found! Back to " ++ Strings.appName ++ "…"
                        }
                }
            , el [ centerX ] <|
                text "Whoops! The page you were looking for is missing."
            , el [ centerX ] <|
                text "You're be redirected shortly…"
            ]
