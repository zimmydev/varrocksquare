module Post exposing (Full, Metadata, Post(..), Preview, StarredPost, UnstarrablePost, UnstarredPost, metadata)

import Author exposing (Author)
import Iso8601
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline exposing (custom, optional, required)
import LoggedInUser
import Post.Body as Body exposing (Body)
import Post.Slug as Slug exposing (Slug)
import Session exposing (Session(..))
import Tag exposing (Tag, Validated)
import Time


type Post payload
    = Starring (StarredPost payload)
    | NotStarring (UnstarredPost payload)
    | CantStar (UnstarrablePost payload)


type StarredPost payload
    = Starred Metadata payload


type UnstarredPost payload
    = Unstarred Metadata payload


type UnstarrablePost payload
    = Unstarrable Metadata payload


type alias Metadata =
    { slug : Slug
    , author : Author
    , title : String
    , description : Maybe String
    , tags : List (Tag Validated)
    , createdAt : Time.Posix
    , editedAt : Maybe Time.Posix
    , starCount : Int
    , commentCount : Int
    }


type Preview
    = Preview


type Full
    = Full Body



-- Obtaining a Post


previewDecoder : Session -> Decoder (Post Preview)
previewDecoder session =
    let
        postDecoder ( isStarred, meta ) =
            case session of
                Guest ->
                    Decode.succeed <| CantStar (Unstarrable meta Preview)

                LoggedIn _ ->
                    case isStarred of
                        True ->
                            Decode.succeed <| Starring (Starred meta Preview)

                        False ->
                            Decode.succeed <| NotStarring (Unstarred meta Preview)
    in
    Decode.succeed Tuple.pair
        |> optional "starred" Decode.bool False
        |> custom (metadataDecoder session)
        |> Decode.andThen postDecoder


fullDecoder : Session -> Decoder (Post Full)
fullDecoder session =
    let
        postDecoder ( isStarred, full, meta ) =
            case session of
                Guest ->
                    Decode.succeed <| CantStar (Unstarrable meta full)

                LoggedIn _ ->
                    if isStarred then
                        Decode.succeed <| Starring (Starred meta full)

                    else
                        Decode.succeed <| NotStarring (Unstarred meta full)
    in
    Decode.succeed (\a b c -> ( a, b, c ))
        |> optional "starred" Decode.bool False
        |> required "body" (Decode.map Full Body.decoder)
        |> custom (metadataDecoder session)
        |> Decode.andThen postDecoder


metadataDecoder : Session -> Decoder Metadata
metadataDecoder session =
    Decode.succeed Metadata
        |> required "slug" Slug.decoder
        |> required "author" (Author.decoder session)
        |> required "title" Decode.string
        |> optional "description" (nullable Decode.string) Nothing
        |> required "tags" (Decode.list Tag.decoder)
        |> required "createdAt" Iso8601.decoder
        |> optional "editedAt" (nullable Iso8601.decoder) Nothing
        |> required "starCount" Decode.int
        |> required "commentCount" Decode.int



-- Info on Post


metadata : Post size -> Metadata
metadata post =
    case post of
        Starring (Starred meta _) ->
            meta

        NotStarring (Unstarred meta _) ->
            meta

        CantStar (Unstarrable meta _) ->
            meta



-- Info on Full Post


body : Post Full -> String
body post =
    Body.toString <|
        case post of
            Starring (Starred _ (Full bod)) ->
                bod

            NotStarring (Unstarred _ (Full bod)) ->
                bod

            CantStar (Unstarrable _ (Full bod)) ->
                bod



-- Transforming a Post


star : UnstarredPost payload -> StarredPost payload
star (Unstarred meta payload) =
    Starred meta payload


unstar : StarredPost payload -> UnstarredPost payload
unstar (Starred meta payload) =
    Unstarred meta payload
