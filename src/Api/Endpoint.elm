module Api.Endpoint exposing (Endpoint, comment, comments, feed, follow, login, post, posts, profile, request, star, user, users)

import CommentId exposing (CommentId)
import Http
import Post.Slug as Slug exposing (Slug)
import Url.Builder exposing (QueryParameter)
import Username exposing (Username)



-- TYPES


type Endpoint
    = Endpoint Href


type alias Href =
    String



-- API REQUESTS


request :
    { method : String
    , headers : List Http.Header
    , endpoint : Endpoint
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }
    -> Cmd msg
request config =
    -- This is just a very thin layer over `Http.request` for using `Endpoint`
    let
        (Endpoint href) =
            config.endpoint
    in
    Http.request
        { method = config.method
        , headers = config.headers
        , url = href
        , body = config.body
        , expect = config.expect
        , timeout = config.timeout
        , tracker = config.tracker
        }



-- ENDPOINTS


login : Endpoint
login =
    endpoint [ "login" ] []


user : Endpoint
user =
    endpoint [ "user" ] []


users : Endpoint
users =
    endpoint [ "users" ] []


profile : Username -> Endpoint
profile username =
    endpoint [ "profiles", Username.toString username ] []


follow : Username -> Endpoint
follow username =
    endpoint [ "profiles", Username.toString username, "follow" ] []


posts : List QueryParameter -> Endpoint
posts queryParams =
    endpoint [ "posts" ] queryParams


feed : List QueryParameter -> Endpoint
feed queryParams =
    endpoint [ "posts", "feed" ] queryParams



-- SPECIFIC POST ENDPOINTS


post : Slug -> Endpoint
post slug =
    endpoint [ "posts", Slug.toString slug ] []


comments : Slug -> Endpoint
comments slug =
    endpoint [ "posts", Slug.toString slug, "comments" ] []


comment : Slug -> CommentId -> Endpoint
comment slug id =
    endpoint [ "posts", Slug.toString slug, "comments", CommentId.toString id ] []


star : Slug -> Endpoint
star slug =
    endpoint [ "posts", Slug.toString slug, "star" ] []



-- HELPERS


endpoint : List String -> List QueryParameter -> Endpoint
endpoint paths queryParams =
    Endpoint <|
        Url.Builder.absolute ("api" :: paths) queryParams
