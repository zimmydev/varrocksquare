module Api.Endpoint exposing (Endpoint, comment, commentsByPost, commentsByUser, createComment, createMessage, createPost, createUser, follow, globalFeed, login, logout, message, messages, myFeed, post, request, searchPosts, searchUsers, star, user)

import CommentId exposing (CommentId)
import Http
import MessageId exposing (MessageId)
import Post.Slug as Slug exposing (Slug)
import Url.Builder as Builder exposing (QueryParameter)
import Username exposing (Username)


type Endpoint
    = Endpoint String



-- Http API Wrapper


{-| This is just a very thin layer over `Http.request`, but using an `Endpoint`.
-}
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



-- Endpoints for Logging In


login : Endpoint
login =
    -- * POST
    endpoint [ "login" ] []


logout : Endpoint
logout =
    -- * POST
    -- TODO: Is this necessary?
    endpoint [ "logout" ] []



-- Endpoints for Posts


globalFeed : Endpoint
globalFeed =
    -- * GET
    endpoint [ "posts" ] [ Builder.string "feed" "global" ]


myFeed : Endpoint
myFeed =
    -- * GET (Must be logged-in)
    endpoint [ "posts" ] [ Builder.string "feed" "personal" ]



-- Endpoints for Searching Posts


searchPosts : String -> Endpoint
searchPosts query =
    -- * GET
    endpoint [ "posts" ] [ Builder.string "query" query ]



-- Endpoints for Post


post : Slug -> Endpoint
post slug =
    -- * GET
    -- * PUT (Must be logged-in + Post owner)
    -- * DELETE (Must be logged-in + Post owner)
    endpoint [ "posts", Slug.toString slug ] []


createPost : Endpoint
createPost =
    -- * POST (Must be logged-in)
    endpoint [ "posts" ] []



-- Endpoints for Starring a Post


star : Slug -> Endpoint
star slug =
    -- * POST (Must be logged-in)
    endpoint [ "posts", Slug.toString slug, "star" ] []



-- Endpoints for Comments


commentsByPost : Slug -> Endpoint
commentsByPost slug =
    -- * GET
    endpoint [ "posts", Slug.toString slug, "comments" ] []


commentsByUser : Username -> Endpoint
commentsByUser username =
    -- * GET
    endpoint [ "users", Username.toString username, "comments" ] []



-- Endpoints for Comment


comment : Slug -> CommentId -> Endpoint
comment postSlug id =
    -- * GET
    -- * PUT (Must be logged-in + Comment owner)
    -- * DELETE (Must be logged-in + Comment owner)
    endpoint [ "posts", Slug.toString postSlug, "comments", CommentId.toString id ] []


createComment : Slug -> Endpoint
createComment postSlug =
    -- POST (Must be logged-in)
    endpoint [ "posts", Slug.toString postSlug, "comments" ] []



-- Endpoints for Searching Users


searchUsers : String -> Endpoint
searchUsers query =
    -- * GET
    endpoint [ "users" ] [ Builder.string "query" query ]



-- Endpoints for User


user : Username -> Endpoint
user username =
    -- * GET
    -- * PUT (Must be logged-in + Account owner)
    -- * DELETE (Must be logged-in + Account owner)
    endpoint [ "users", Username.toString username ] []


createUser : Endpoint
createUser =
    -- * POST
    endpoint [ "users" ] []



-- Endpoints for Following a User


follow : Username -> Endpoint
follow username =
    -- * POST (Must be logged-in)
    -- TODO: Do we need an /unfollow route as well?
    endpoint [ "users", Username.toString username, "follow" ] []



-- Endpoints for Messages


messages : Username -> Endpoint
messages username =
    -- * GET (Must be logged-in + Message owner/recipient)
    endpoint [ "users", Username.toString username, "messages" ] []



-- Endpoints for Message


message : Username -> MessageId -> Endpoint
message username id =
    -- * GET (Must be logged-in + Message owner/recipient)
    endpoint [ "users", Username.toString username, "messages", MessageId.toString id ] []


createMessage : Username -> Endpoint
createMessage username =
    -- * POST (Must be logged-in; reliquishes ownernership of the Message to the recipient)
    endpoint [ "users", Username.toString username, "outbox" ] []



-- Helpers


endpoint : List String -> List QueryParameter -> Endpoint
endpoint paths queryParams =
    Endpoint <|
        Builder.absolute ("api" :: paths) queryParams
