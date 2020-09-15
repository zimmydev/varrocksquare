module Ui exposing (DeviceProfile(..), abridge, credentialed, label, pill, profileDevice, responsive, spinner)

import Api exposing (AuthToken)
import Config.Links as Links
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Html
import Html.Attributes
import Session exposing (Session(..))



-- VISUAL ELEMENTS


spinner : List (Attribute msg) -> Element msg
spinner attrs =
    el attrs <|
        html <|
            Html.div
                [ Html.Attributes.class "spinner" ]
                [ Html.div [] []
                , Html.div [] []
                , Html.div [] []
                , Html.div [] []
                ]



-- VISUAL ELEMENT MODIFIERS


label : String -> Element msg -> Element msg
label str element =
    row [ spacing 6 ]
        [ element, text str ]


pill : Int -> Element msg -> Element msg
pill count element =
    if count > 0 then
        row [ spacing 6 ]
            [ element, el Styles.pill (text (String.fromInt count)) ]

    else
        element


credentialed : Session -> { loggedIn : AuthToken -> Element msg, guest : Element msg } -> Element msg
credentialed session { loggedIn, guest } =
    case Session.authToken session of
        Nothing ->
            guest

        Just tok ->
            loggedIn tok



-- PRESENTING STRINGS


abridge : Int -> String -> String
abridge length str =
    let
        ellipses s =
            if String.length str > length then
                s ++ "…"

            else
                s
    in
    str
        |> String.left length
        |> String.trimRight
        |> ellipses



-- RESPONSIVENESS


type DeviceProfile
    = Full
    | Compact


responsive : DeviceProfile -> { compact : a, full : a } -> a
responsive deviceProfile { compact, full } =
    case deviceProfile of
        Compact ->
            compact

        Full ->
            full


profileDevice : Int -> DeviceProfile
profileDevice width =
    if width >= 1180 then
        Full

    else
        Compact
