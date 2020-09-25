module Post.Body exposing (Body, toString, view)

import Element exposing (Element)


type alias MarkdownString =
    String


type Body
    = Body MarkdownString



-- Converting a Body


toString : Body -> String
toString (Body md) =
    md


view : Body -> Element msg
view (Body md) =
    -- TODO: Convert markdown to HTML
    Element.text md
