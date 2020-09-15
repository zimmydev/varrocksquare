module Config.Assets exposing (..)

import Url.Builder as Builder



--TYPES


type alias Href =
    String



-- IMAGES


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



-- IMAGE HELPERS


image : String -> Href
image filename =
    Builder.absolute [ "assets", "images", filename ] []



-- ICONS


icon : String -> Href
icon filename =
    -- Helper function
    Builder.absolute [ "assets", "icons", filename ] []
