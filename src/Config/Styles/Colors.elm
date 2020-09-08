module Config.Styles.Colors exposing (black, blue, darkGrey, fadedInk, green, indigo, ink, lightGrey, orange, parchment, pink, red, white)

import Element exposing (Color, rgb255)



-- PRIMARY


black : Color
black =
    rgb255 28 28 30


white : Color
white =
    -- #f2f2f7
    rgb255 242 242 247


blue : Color
blue =
    rgb255 10 132 255


red : Color
red =
    rgb255 255 69 58


green : Color
green =
    rgb255 48 209 88


orange : Color
orange =
    rgb255 255 159 10


indigo : Color
indigo =
    rgb255 94 92 230


pink : Color
pink =
    rgb255 255 55 95



-- OTHER


ink : Color
ink =
    rgb255 47 22 0


fadedInk : Color
fadedInk =
    rgb255 111 84 54


parchment : Color
parchment =
    rgb255 188 159 118



-- GREYSCALE


lightGrey : Int -> Color
lightGrey level =
    case level of
        1 ->
            rgb255 229 229 234

        2 ->
            rgb255 209 209 214

        3 ->
            rgb255 199 199 204

        4 ->
            rgb255 174 174 178

        _ ->
            white


darkGrey : Int -> Color
darkGrey level =
    case level of
        1 ->
            rgb255 44 44 46

        2 ->
            rgb255 58 58 60

        3 ->
            rgb255 72 72 74

        4 ->
            rgb255 99 99 102

        _ ->
            black
