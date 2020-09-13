module Keyboard exposing (Key(..), onKeyDown, onShortcut)

import Browser.Events as Events
import Config.Links as Links exposing (Href)
import Config.Shortcuts as Shortcuts
import Json.Decode as Decode exposing (Decoder)


type Key
    = Character Char
    | Control String


onKeyDown : Sub Key
onKeyDown =
    Events.onKeyDown decoder


decoder : Decoder Key
decoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Key
toKey string =
    case String.uncons string of
        Just ( char, "" ) ->
            Character char

        _ ->
            Control string



-- SHORTCUT KEYMAPPING


onShortcut : Sub Href
onShortcut =
    Events.onKeyDown shortcutDecoder


shortcutDecoder : Decoder Href
shortcutDecoder =
    Decode.map toHref decoder


toHref : Key -> Href
toHref key =
    case key of
        Character char ->
            Links.internal.inert

        Control ctrl ->
            Shortcuts.get ctrl
