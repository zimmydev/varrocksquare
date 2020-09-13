module Keyboard exposing (Key(..), onKeyDown, onKeyPress)

import Browser.Events as Events
import Json.Decode as Decode


type Key
    = Character Char
    | Control String


onKeyPress : Sub Key
onKeyPress =
    Events.onKeyPress decoder


onKeyDown : Sub Key
onKeyDown =
    Events.onKeyDown decoder


decoder : Decode.Decoder Key
decoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Key
toKey string =
    case String.uncons string of
        Just ( char, "" ) ->
            Character char

        _ ->
            Control string
