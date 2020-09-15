module Config.ExternalHref exposing (..)

import Url.Builder as Builder



-- TYPES


type alias Href =
    String



-- EXTERNAL HREFS


companyWebsite : Href
companyWebsite =
    -- TODO: Establish a better company website link
    Builder.crossOrigin "https://github.com/zimmydev" [] []


github : Href
github =
    Builder.crossOrigin "https://github.com" [ "zimmydev", "varrocksquare" ] []


discord : Href
discord =
    Builder.crossOrigin "https://discord.gg" [ "RA8bujG" ] []


donate : Href
donate =
    -- TODO: Currently intert; establish a donation link
    Builder.relative [] []


icons8 : Href
icons8 =
    Builder.crossOrigin "https://icons8.com" [] []



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
