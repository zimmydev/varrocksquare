module Avatar exposing (Avatar, decoder, default, encode, href, view)

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
    Avatar <| Assets.image "default-avatar.png"



-- Serializing an Avatar


decoder : Decoder Avatar
decoder =
    Decode.string
        |> Decode.map Avatar


encode : Avatar -> Value
encode avatar =
    if avatar == default then
        Encode.null

    else
        Encode.string (href avatar)



-- Info on Avatar


href : Avatar -> Href
href (Avatar hrf) =
    hrf



-- Converting an Avatar


view : Int -> Avatar -> Element msg
view size avatar =
    Element.el (Styles.avatar size (href avatar))
        Element.none
