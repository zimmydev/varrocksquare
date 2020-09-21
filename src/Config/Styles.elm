module Config.Styles exposing (alert, alertArea, avatar, button, content, contentHeader, donate, focus, footer, footerElement, highlighted, inputLabel, logo, navbar, navbarItem, navbarSpacing, page, pill, redirectPage, root, searchPlaceholder, searchbar, smallSpacing, spinner)

import Config.Assets as Assets
import Config.Styles.Colors as Colors
import Device
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html.Attributes exposing (class)
import Icon



-- TYPES


type alias Href =
    String



-- COMMON ATTRIBUTES (FOR INTERNAL USE)


headerFooterBg : Attribute msg
headerFooterBg =
    Background.color Colors.black


zeroEdges : { bottom : number, left : number, right : number, top : number }
zeroEdges =
    { top = 0, left = 0, right = 0, bottom = 0 }


shadow : { blur : number, color : Color, offset : ( number, number ), size : number }
shadow =
    { offset = ( 4, 4 )
    , size = -5
    , blur = 16
    , color = Colors.black
    }


contentRoundness : number
contentRoundness =
    10



-- STYLE CONFIGURATIONS


root : List (Attribute msg)
root =
    [ paddingEach { zeroEdges | top = 72 }
    , clipX
    , Font.color Colors.white
    , Font.size (fontSizeBy 1)
    , Font.family [ Font.typeface "Nunito", Font.sansSerif ]
    , Background.tiled Assets.appBackground
    ]


navbar : Device.Profile -> List (Attribute msg)
navbar devpro =
    [ Region.navigation
    , width fill
    , paddingXY 24 16
    , navbarSpacing
    , Font.size <|
        Device.responsive devpro
            { compact = fontSizeBy 2
            , full = fontSizeBy -1
            }
    , headerFooterBg
    , Border.shadow shadow
    ]


logo : List (Attribute msg)
logo =
    [ spacing 8
    , Font.bold
    , Font.size (fontSizeBy 2)
    , Font.family [ Font.typeface "Cinzel Decorative", Font.serif ]
    ]


navbarItem : Bool -> List (Attribute msg)
navbarItem isActive =
    if isActive then
        [ Font.bold ]

    else
        [ Font.color (Colors.lightGrey 1) ]


pill : List (Attribute msg)
pill =
    [ height (px 16)
    , paddingXY 6 3
    , Font.bold
    , Font.color Colors.white
    , Font.size (fontSizeBy -2)
    , Background.color Colors.red
    , Border.rounded 8
    ]


avatar : Int -> Href -> List (Attribute msg)
avatar size href =
    [ width (px size)
    , height (px size)
    , Background.image href
    , Border.rounded (size // 2)
    ]


alertArea : List (Attribute msg)
alertArea =
    [ alignBottom
    , moveUp 24
    , moveRight 24
    , spacing 12
    ]


alert : Color -> List (Attribute msg)
alert backgroundColor =
    [ paddingXY 12 8
    , Font.bold
    , Font.color Colors.white
    , Background.color backgroundColor
    , Border.shadow shadow
    , Border.rounded 8
    , Border.width 2
    , Border.color Colors.white
    ]


page : List (Attribute msg)
page =
    [ Region.mainContent
    , width (fillPortion 10)
    , height fill
    , paddingEach { top = 16, left = 32, right = 32, bottom = 32 }
    , spacing 32
    , scrollbarY
    ]


content : List (Attribute msg)
content =
    [ width (fill |> minimum 360 |> maximum 1080)
    , padding 25
    , spacing 25
    , Font.justify
    , Font.color Colors.ink
    , Background.tiled Assets.contentBackground
    , Border.shadow shadow
    , Border.rounded contentRoundness
    ]


redirectPage : List (Attribute msg)
redirectPage =
    [ width fill
    , height fill
    , Font.bold
    , Font.size (fontSizeBy 3)
    ]


footer : List (Attribute msg)
footer =
    [ Region.footer
    , width fill
    , paddingXY 24 12
    , spacing 24
    , alignBottom
    , Font.color (Colors.darkGrey 2)
    , Font.size (fontSizeBy -1)
    , headerFooterBg
    ]


searchbar : List (Attribute msg)
searchbar =
    [ htmlAttribute (Html.Attributes.id "searchbar")
    , width fill
    , Font.color Colors.black
    , Background.color Colors.white
    , Border.shadow { shadow | size = 0, offset = ( 0, 0 ), blur = 2 }
    , Border.rounded contentRoundness
    ]


searchPlaceholder : List (Attribute msg)
searchPlaceholder =
    [ Font.color (Colors.lightGrey 4) ]


spinner : List (Attribute msg)
spinner =
    [ centerX ]


highlighted : List (Attribute msg)
highlighted =
    [ Font.bold
    , Font.color Colors.blue
    ]


donate : Device.Profile -> List (Attribute msg)
donate devpro =
    let
        fontSize =
            Device.responsive devpro
                { compact = fontSizeBy -1
                , full = 12
                }
    in
    [ alignRight
    , Font.size fontSize
    , Font.color Colors.green
    ]


button : List (Attribute msg)
button =
    [ paddingXY 15 10
    , Font.color Colors.green
    , Border.color Colors.green
    , Border.width 3
    , Border.rounded contentRoundness
    ]


inputLabel : List (Attribute msg)
inputLabel =
    [ centerY
    , width (px 200)
    , Font.bold
    ]


footerElement : List (Attribute msg)
footerElement =
    [ width fill ]



-- OTHER STYLE CONFIGURATIONS


contentHeader : Int -> List (Attribute msg)
contentHeader heading =
    let
        h =
            -- Clamp between 1..3, inclusive
            heading |> max 1 |> min 6
    in
    [ Region.heading h
    , Font.semiBold
    , Font.size <| fontSizeBy (4 - min 3 h)
    , Font.family [ Font.typeface "Cinzel", Font.serif ]
    ]



-- MISC. EXPOSED STYLE CONFIGURATIONS


navbarSpacing : Attribute msg
navbarSpacing =
    spacing 24


smallSpacing : Attribute msg
smallSpacing =
    spacing 7


focus : FocusStyle
focus =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }



-- FONT SCALING


fontSizeBy : Int -> Int
fontSizeBy =
    modular 16 1.25
        >> round
