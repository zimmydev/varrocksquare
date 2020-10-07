module Avatar exposing (Avatar, decoder, default, encode, href, view)

import Config.Assets as Assets
import Config.Styles as Styles
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder, nullable, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode exposing (Value)


type Avatar
    = Avatar Href


type alias Href =
    String



-- Obtaining an Avatar


default : Avatar
default =
    Avatar "data:image/png;base64,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"



-- Serializing an Avatar


decoder : Decoder Avatar
decoder =
    nullable string
        |> Decode.andThen
            (\maybeHref ->
                case maybeHref of
                    Nothing ->
                        Decode.succeed default

                    Just hrf ->
                        Decode.succeed (Avatar hrf)
            )


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
