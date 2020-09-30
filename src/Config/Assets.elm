module Config.Assets exposing (icon, image)

import Url.Builder as Builder


type alias Href =
    String



-- Image Assets


image : String -> Href
image filename =
    Builder.absolute [ "assets", "images", filename ] []



-- Icon Assets


icon : String -> Href
icon filename =
    -- Helper function
    Builder.absolute [ "assets", "icons", filename ] []
