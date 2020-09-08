module Ui exposing (DeviceSize, isCompact, labelRight, pill, responsive)

import Config.Links as Links
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)



{- THIS MODULE FOR REUSABLE VISUAL ELEMENTS -}


labelRight : String -> Element msg -> Element msg
labelRight label element =
    row [ spacing space ]
        [ element, text label ]


pill : Int -> Element msg -> Element msg
pill count element =
    if count > 0 then
        row [ spacing space ]
            [ element, el Styles.pill (text (String.fromInt count)) ]

    else
        element



-- HELPERS


space : Int
space =
    6



-- RESPONSIVENESS


type alias DeviceSize =
    { width : Int
    , height : Int
    }


responsive : DeviceSize -> a -> a -> a
responsive deviceSize a b =
    if isCompact deviceSize then
        b

    else
        a


isCompact : DeviceSize -> Bool
isCompact { width } =
    width < 1180
