module Config.Links exposing (Href, api, external, images, internal)

import Url.Builder as Builder
import Username



-- TYPES


type alias Href =
    String



-- ASSETS


images =
    { logo =
        image "logo.png"
    , icon =
        icon
    , appBackground =
        image "bg.png"
    , contentBackground =
        image "content-bg.png"
    , defaultAvatar =
        image "default-avatar.png"
    , custom =
        image
    }


image : String -> Href
image filename =
    Builder.absolute [ "assets", "images", filename ] []


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
