module Avatar exposing (Avatar, debug, decoder, default, encode, view)

import Config.Assets as Assets
import Config.Styles as Styles
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- TYPES


type Avatar
    = Avatar Href


type alias Href =
    String



-- CREATE


default : Avatar
default =
    Avatar Assets.defaultAvatar


decoder : Decoder Avatar
decoder =
    Decode.map Avatar Decode.string



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
    Avatar (Assets.image "bart.png")
