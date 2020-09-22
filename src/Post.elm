module Post exposing (Full, Post, Preview)

import Post.Body exposing (Body)
import Post.Slug exposing (Slug)
import Time
import User exposing (User)
import Username exposing (Username)


type Post p
    = Post Metadata p


type Preview
    = Preview String


type Full
    = Full Body


type alias Metadata =
    { slug : Slug
    , title : String
    , author : User
    , tags : List String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , starred : Bool
    , starCount : Int
    , commentCount : Int
    }
