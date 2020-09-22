module Config.Assets exposing (..)

import Url.Builder as Builder


type alias Href =
    String



-- Image Assets


logo : Href
logo =
    image "logo.png"


appBackground : Href
appBackground =
    image "bg.png"


contentBackground : Href
contentBackground =
    image "content-bg.png"


defaultAvatar : Href
defaultAvatar =
    image "default-avatar.png"


notFoundImage : Href
notFoundImage =
    image "not-found.png"



-- Image Assets (Helpers)


image : String -> Href
image filename =
    Builder.absolute [ "assets", "images", filename ] []



-- Icon Assets


icon : String -> Href
icon filename =
    -- Helper function
    Builder.absolute [ "assets", "icons", filename ] []
