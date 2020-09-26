module Post.Body exposing (Body, decoder, toString, view)

import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)


type alias MarkdownString =
    String


type Body
    = Body MarkdownString



-- Obtaining a Body


decoder : Decoder Body
decoder =
    Decode.string
        |> Decode.map Body



-- Converting a Body


toString : Body -> String
toString (Body md) =
    md


view : Body -> Element msg
view (Body md) =
    -- TODO: Convert markdown to HTML
    Element.text md
