module Post exposing (Post)

import Post.Body exposing (Body)
import Time



-- TYPES


type Post
    = Preview Metadata
    | Post Body Metadata


type alias Metadata =
    { slug : String
    , title : String
    , description : String
    , author : String
    , createdAt : Time.Posix
    , starred : Bool
    , starredCount : Int
    }
