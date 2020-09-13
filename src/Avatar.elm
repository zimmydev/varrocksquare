module Avatar exposing (Avatar, debug, decoder, encode, guest, view)

import Config.Links as Links exposing (Href)
import Config.Styles as Styles
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- TYPES


type Avatar
    = Avatar Href



-- CREATE


guest : Avatar
guest =
    Avatar Links.assets.guestAvatar


decoder : Decoder Avatar
decoder =
    Decode.string
        |> Decode.map Avatar



-- TRANSFORM


encode : Avatar -> Value
encode (Avatar href) =
    Encode.string href


view : Int -> Avatar -> Element msg
view size (Avatar href) =
    Element.el (Styles.navatar size href)
        Element.none



-- DEBUG


debug : Avatar
debug =
    Avatar (Links.debugAsset "bart.png")
