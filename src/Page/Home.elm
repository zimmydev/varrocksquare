module Page.Home exposing (view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)



-- Views


view : Page msg
view =
    { navbarItem = Page.Other
    , title = "Home"
    , body = lazy (\_ -> body) ()
    }


body : Element msg
body =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text "Home"
        ]
