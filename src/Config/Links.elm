module Config.Links exposing (Href, asset, assets, external, icon, internal)

import Url.Builder as Builder
import Username



-- TYPES


type alias Href =
    String



-- ASSETS


asset : String -> Href
asset filename =
    -- Helper function
    Builder.absolute [ "assets", filename ] []


icon : String -> Href
icon filename =
    -- Helper function
    Builder.absolute [ "assets", "icons", filename ] []


assets =
    { logo =
        asset "logo.png"
    , appBackgroundDark =
        asset "bg-dark.png"
    , contentBackgroundDark =
        asset "bg-content-dark.png"
    , icon =
        icon
    , defaultAvatar =
        asset "default-avatar.png"
    }



-- INTERNAL LINKS


path : List String -> Href
path p =
    Builder.absolute p []


internal =
    { inert =
        Builder.relative [] []
    , home =
        path []
    , explore =
        path [ "explore" ]
    , search =
        path [ "search" ]
    , saved =
        path [ "saved" ]
    , messages =
        path [ "messages" ]
    , tools =
        path [ "tools" ]
    , help =
        path [ "help" ]
    , profileFor =
        \username ->
            path [ "profile", Username.toString username ]
    , settings =
        path [ "settings" ]
    }



-- EXTERNAL LINKS


external : { discord : String, donate : String, github : String, icons8 : String }
external =
    { github =
        Builder.crossOrigin "https://github.com" [ "zimmydev", "varrocksquare" ] []
    , discord =
        Builder.crossOrigin "https://discord.gg" [ "RA8bujG" ] []
    , donate =
        -- TODO: establish a proper donation link
        internal.inert
    , icons8 =
        Builder.crossOrigin "https://icons8.com" [] []
    }
