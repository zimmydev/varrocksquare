module Post.Body exposing (Body, view)

import Element exposing (Element)



-- TYPES


type alias MarkdownString =
    String


type Body
    = Body MarkdownString



-- TRANSFORM


view : Body -> Element msg
view (Body md) =
    -- TODO: Convert markdown to HTML
    Element.text md
