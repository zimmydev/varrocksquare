module Post exposing (Full, Post, Preview)

import Post.Body exposing (Body)
import Post.Slug exposing (Slug)
import Time
import Username exposing (Username)


type Post p
    = Post p Metadata


type Preview
    = Preview String


type Full
    = Full Body


type alias Metadata =
    { slug : Slug
    , title : String
    , author : Username
    , createdAt : Time.Posix
    , commentCount : Int
    , viewCount : Int
    , savedCount : Int
    , saved : Bool
    , tags : List String
    }
