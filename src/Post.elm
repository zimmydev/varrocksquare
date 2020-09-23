module Post exposing (Full, Post, Preview, metadata)

import Author exposing (Author)
import Post.Body exposing (Body)
import Post.Slug exposing (Slug)
import Time


type Post either
    = Post Metadata either


type Preview
    = Preview String


type Full
    = Full Body


type alias Metadata =
    { slug : Slug
    , title : String
    , author : Author
    , tags : List String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , starred : Bool
    , starCount : Int
    , commentCount : Int
    }



-- Info on Post


metadata : Post either -> Metadata
metadata (Post meta _) =
    meta
