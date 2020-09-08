module Page.Home exposing (view)

import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Lazy exposing (..)


type alias Model =
    ()


view : Model -> Element msg
view _ =
    column Styles.page
        [ textColumn Styles.content
            [ paragraph (Styles.contentHeader 1) [ text "Some kind of post" ]
            , paragraph [ spacing 8 ] [ text Strings.loremIpsum ]
            ]
        , textColumn Styles.content
            [ paragraph (Styles.contentHeader 1) [ text "Some kind of other post" ]
            , paragraph [ spacing 8 ] [ text Strings.loremIpsum ]
            ]
        ]
