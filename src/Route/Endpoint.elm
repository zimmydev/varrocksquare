module Route.Endpoint exposing (Endpoint, api, toHref)

import Config.Links exposing (Href)
import Url.Builder as Builder



-- TYPES
{- An Endpoint is e.g. the server, an API, etc.; we want to get these right,
   so you can only obtain one through this narrow API, and the Http request
   API only operates in terms of this type.
-}


type Endpoint
    = Endpoint Href



-- INFO


toHref : Endpoint -> Href
toHref (Endpoint href) =
    href



-- HELPER


api : List String -> List Builder.QueryParameter -> Endpoint
api path =
    Endpoint << Builder.absolute ("api" :: path)
