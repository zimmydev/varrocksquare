module Avatar exposing (Avatar, debug, default, view)

import Config.Links as Links
import Config.Styles as Styles
import Element exposing (Element)



-- TYPES


type Avatar
    = Avatar String



-- CREATE


default : Avatar
default =
    Avatar Links.assets.defaultAvatar



-- TRANSFORM


view : Int -> Avatar -> Element msg
view size (Avatar href) =
    Element.el (Styles.navatar size href)
        Element.none



-- DEBUG


debug : Avatar
debug =
    Avatar Links.debugAvatar
