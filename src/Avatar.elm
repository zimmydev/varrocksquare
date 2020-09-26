module Avatar exposing (Avatar, debug, decoder, default, encode, href, view)

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
encode (Avatar hrf) =
    Encode.string hrf


href : Avatar -> Href
href (Avatar hrf) =
    hrf


view : Int -> Avatar -> Element msg
view size (Avatar hrf) =
    Element.el (Styles.avatar size hrf)
        Element.none



-- Debugging an Avatar


debug : Avatar
debug =
    Avatar (Assets.image "bart.png")
