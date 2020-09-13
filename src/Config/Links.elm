module Config.Links exposing (Href, api, assets, debugAsset, external, internal)

import Url.Builder as Builder
import Username



-- TYPES


type alias Href =
    String



-- ASSETS


assets =
    { logo =
        asset "logo.png"
    , appBackgroundDark =
        asset "bg-dark.png"
    , contentBackgroundDark =
        asset "bg-content-dark.png"
    , icon =
        icon
    , guestAvatar =
        asset "default-avatar.png"
    }


asset : String -> Href
asset filename =
    Builder.absolute [ "assets", filename ] []


icon : String -> Href
icon filename =
    -- Helper function
    Builder.absolute [ "assets", "icons", filename ] []



-- INTERNAL LINKS


internal =
    { inert =
        Builder.relative [] []
    , home =
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
            Builder.absolute [ "profile", Username.toString username ] []
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
        internal.inert
    , icons8 =
        Builder.crossOrigin "https://icons8.com" [] []
    }



-- SERVER API


api =
    { login =
        apiRoute [ "login" ] []
    , posts =
        \maybeSort ->
            case maybeSort of
                Just sortType ->
                    apiRoute [ "posts" ] [ Builder.string "sort" sortType ]

                Nothing ->
                    apiRoute [ "posts" ] []
    }


apiRoute : List String -> List Builder.QueryParameter -> Href
apiRoute path =
    Builder.absolute ("api" :: path)



-- DEBUG


debugAsset : String -> Href
debugAsset =
    asset
