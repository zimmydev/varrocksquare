module Ui exposing (DeviceSize, credentialed, isCompact, labelRight, pill, responsive, spinner)

import Config.Links as Links
import Config.Strings as Strings
import Config.Styles as Styles
import Credentials exposing (Credentials)
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


labelRight : String -> Element msg -> Element msg
labelRight label element =
    row [ spacing 6 ]
        [ element, text label ]


pill : Int -> Element msg -> Element msg
pill count element =
    if count > 0 then
        row [ spacing 6 ]
            [ element, el Styles.pill (text (String.fromInt count)) ]

    else
        element


credentialed : Session -> { loggedIn : Credentials -> Element msg, guest : Element msg } -> Element msg
credentialed sess { loggedIn, guest } =
    case sess of
        Guest _ ->
            guest

        LoggedIn _ cred _ _ ->
            loggedIn cred



-- RESPONSIVENESS


type alias DeviceSize =
    { width : Int
    , height : Int
    }


responsive : DeviceSize -> { compact : a, full : a } -> a
responsive deviceSize { compact, full } =
    if isCompact deviceSize then
        compact

    else
        full


isCompact : DeviceSize -> Bool
isCompact { width } =
    width < 1180
