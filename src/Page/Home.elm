module Page.Home exposing (view)

import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)
import Page exposing (Page)
import Utils.String exposing (abridge)


type alias Model =
    ()


view : Model -> Page msg
view _ =
    { navbarItem = Page.Other
    , title = "Home"
    , body =
        column Styles.page
            [ textColumn Styles.content
                [ paragraph (Styles.contentHeader 1) [ text "Some kind of post" ]
                , paragraph [ spacing 8 ] [ text (abridge 1500 Strings.loremIpsum) ]
                ]
            , textColumn Styles.content
                [ paragraph (Styles.contentHeader 1) [ text "Some kind of other post" ]
                , paragraph [ spacing 8 ] [ text (abridge 1500 Strings.loremIpsum) ]
                ]
            ]
    }
