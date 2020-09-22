module Post.Body exposing (Body, view)

import Element exposing (Element)


type alias MarkdownString =
    String


type Body
    = Body MarkdownString



-- Converting a Body


view : Body -> Element msg
view (Body md) =
    -- TODO: Convert markdown to HTML
    Element.text md
