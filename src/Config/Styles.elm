module Config.Styles exposing (content, contentHeader, focus, footer, footerCenter, footerLeft, footerRight, highlighted, labeledElement, logo, navatar, navbar, notification, notificationArea, page, pageMargin, pill, root, searchPlaceholder, searchbar)

import Config.Links as Links exposing (Href)
import Config.Styles.Colors as Colors
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html.Attributes exposing (class)
import Icon



-- COMMON ATTRIBUTES (FOR INTERNAL USE)


navbarBg : Attribute msg
navbarBg =
    Background.color Colors.black


zeroPadding : { bottom : number, left : number, right : number, top : number }
zeroPadding =
    { top = 0, left = 0, right = 0, bottom = 0 }


shadow : { blur : number, color : Color, offset : ( number, number ), size : number }
shadow =
    { offset = ( 4, 4 )
    , size = -5
    , blur = 16
    , color = Colors.black
    }


pageBoxRoundness : number
pageBoxRoundness =
    10



-- STYLE CONFIGURATIONS


root : List (Attribute msg)
root =
    [ paddingEach { zeroPadding | top = 72 }
    , clipX
    , Font.color Colors.white
    , Font.size (fontSizeBy 1)
    , Font.family [ Font.typeface "Nunito Sans", Font.sansSerif ]
    , Background.tiled Links.assets.appBackgroundDark
    ]


navbar : List (Attribute msg)
navbar =
    [ Region.navigation
    , width fill
    , paddingXY 24 16
    , spacing 24
    , Font.size 14
    , navbarBg
    , Border.shadow shadow
    ]


pill : List (Attribute msg)
pill =
    [ height (px 16)
    , paddingXY 6 3
    , Font.bold
    , Font.color Colors.white
    , Font.size 11
    , Background.color Colors.red
    , Border.rounded 8
    ]


navatar : Int -> Href -> List (Attribute msg)
navatar size href =
    [ width (px size)
    , height (px size)
    , Background.image href
    , Border.rounded (size // 2)
    ]


logo : List (Attribute msg)
logo =
    [ spacing 8
    , Font.size 20
    , Font.bold
    , Font.family [ Font.typeface "Cinzel Decorative", Font.serif ]
    ]


notification : Color -> List (Attribute msg)
notification backgroundColor =
    [ paddingXY 12 8
    , Font.bold
    , Font.color Colors.white
    , Background.color backgroundColor
    , Border.shadow shadow
    , Border.rounded 8
    , Border.width 2
    , Border.color Colors.white
    ]


notificationArea : List (Attribute msg)
notificationArea =
    [ width fill
    , alignBottom
    , moveUp 24
    , moveRight 24
    , spacing 12
    ]


pageMargin : List (Attribute msg)
pageMargin =
    [ width (fillPortion 1) ]


page : List (Attribute msg)
page =
    [ Region.mainContent
    , width (fillPortion 10)
    , height fill
    , paddingEach { top = 16, left = 32, right = 32, bottom = 32 }
    , spacing 32
    , scrollbarY
    ]


pageBox : List (Attribute msg)
pageBox =
    [ width (fill |> minimum 360 |> maximum 1080)
    , Border.shadow shadow
    , Border.rounded pageBoxRoundness
    ]


content : List (Attribute msg)
content =
    padding 25
        :: spacing 15
        :: Font.color Colors.ink
        :: Font.justify
        :: Background.tiled Links.assets.contentBackgroundDark
        :: pageBox


footer : List (Attribute msg)
footer =
    [ Region.footer
    , width fill
    , paddingXY 24 12
    , spacing 24
    , alignBottom
    , Font.color (Colors.darkGrey 3)
    , Font.size 12
    , navbarBg
    ]


searchbar : List (Attribute msg)
searchbar =
    [ htmlAttribute (Html.Attributes.id "searchbar")
    , width fill
    , Font.color Colors.black
    , Background.color Colors.white
    , Border.shadow { shadow | size = 0, offset = ( 0, 0 ), blur = 2 }
    , Border.rounded pageBoxRoundness
    ]


searchPlaceholder : List (Attribute msg)
searchPlaceholder =
    [ Font.color (Colors.lightGrey 4) ]


highlighted : List (Attribute msg)
highlighted =
    [ Font.bold, Font.color Colors.blue ]


footerLeft : List (Attribute msg)
footerLeft =
    [ width (fillPortion 1), Font.alignLeft ]


footerCenter : List (Attribute msg)
footerCenter =
    [ width (fillPortion 1), Font.center ]


footerRight : List (Attribute msg)
footerRight =
    [ width (fillPortion 1), Font.alignRight ]



-- OTHER STYLE CONFIGURATIONS


contentHeader : Int -> List (Attribute msg)
contentHeader heading =
    let
        h =
            -- Clamp between 1..3, inclusive
            heading |> max 1 |> min 6
    in
    [ Region.heading h
    , Font.bold
    , Font.size <| fontSizeBy (4 - min 3 h)
    , Font.family [ Font.typeface "Cinzel", Font.serif ]
    ]


labeledElement : List (Attribute msg)
labeledElement =
    -- Default attributes applied to all 'labeled' UI Elements (icon + text)
    [ spacing 6 ]



-- MISC. EXPOSED STYLE CONFIGURATIONS


focus : FocusStyle
focus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }



-- FONT SCALING


fontSizeBy : Int -> Int
fontSizeBy =
    modular 16 1.25 >> round