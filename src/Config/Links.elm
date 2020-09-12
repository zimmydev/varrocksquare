module Config.Links exposing (Href, assets, dummy, external, icon, internal)

import Url.Builder as Builder



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


dummy : Href
dummy =
    Builder.relative [] []


internal =
    { home =
        Builder.absolute [] []
    , explore =
        Builder.absolute [ "explore" ] []
    , search =
        Builder.absolute [ "search" ] []
    , saved =
        Builder.absolute [ "saved" ] []
    , messages =
        Builder.absolute [ "messages" ] []
    , tools =
        Builder.absolute [ "tools" ] []
    , help =
        Builder.absolute [ "help" ] []
    , profileFor =
        \username ->
            Builder.absolute [ "profile" ] [ Builder.string "user" username ]
    , settings =
        Builder.absolute [ "settings" ] []
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
        Builder.absolute [] []
    , icons8 =
        Builder.crossOrigin "https://icons8.com" [] []
    }
