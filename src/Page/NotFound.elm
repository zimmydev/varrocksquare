module Page.NotFound exposing (view)

import Config.Assets as Assets
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)
import Route



-- Views


view : Page msg
view =
    { navbarItem = Page.Other
    , title = "Page not found!"
    , body = lazy (\_ -> body) ()
    }


body : Element msg
body =
    el Styles.seguePage <|
        column Styles.segueContent
            [ Route.link [ centerX ] <|
                { route = Route.Home
                , body =
                    image []
                        { src = Assets.image "not-found.png"
                        , description = "Page not found!"
                        }
                }
            , el [ centerX ] <|
                text "Whoops! The page you were looking for was not found."
            , el [ centerX ] <|
                text "You'll be redirected shortly…"
            ]
