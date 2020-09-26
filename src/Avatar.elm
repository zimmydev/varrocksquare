module Avatar exposing (Avatar, debug, decoder, default, encode, view)

import Config.Assets as Assets
import Config.Styles as Styles
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode exposing (Value)


type Avatar
    = Avatar Href


type alias Href =
    String



-- Obtaining an Avatar


default : Avatar
default =
    Avatar Assets.defaultAvatar


decoder : Decoder Avatar
decoder =
    Decode.string
        |> Decode.map Avatar



-- Converting an Avatar


encode : Avatar -> Value
encode (Avatar href) =
    Encode.string href


view : Int -> Avatar -> Element msg
view size (Avatar href) =
    Element.el (Styles.avatar size href)
        Element.none



-- Debugging an Avatar


debug : Avatar
debug =
    Avatar (Assets.image "bart.png")
