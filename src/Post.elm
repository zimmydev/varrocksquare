module Post exposing (Full, Post, Preview, metadata)

import Author exposing (Author)
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (custom, optional, required)
import LoggedInUser
import Post.Body as Body exposing (Body)
import Post.Slug as Slug exposing (Slug)
import Session exposing (Session)
import Tag exposing (Tag, Validated)
import Time


type Post style
    = Starring (StarredPost style)
    | NotStarring (UnstarredPost style)
    | CantStar (UnstarrablePost style)


type StarredPost style
    = Starred Metadata style


type UnstarredPost style
    = Unstarred Metadata style


type UnstarrablePost style
    = Unstarrable Metadata style


type Preview
    = Preview (Maybe String)


type Full
    = Full Body


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



-- Obtaining a Post


previewDecoder : Session -> Decoder (Post Preview)
previewDecoder session =
    let
        postDecoder ( isStarred, meta ) =
            let
                preview =
                    Preview meta.description
            in
            Session.withLoggedInUser session
                { guest = Decode.succeed <| CantStar (Unstarrable meta preview)
                , loggedIn =
                    \loggedInUser ->
                        case isStarred of
                            Just True ->
                                Decode.succeed <| Starring (Starred meta preview)

                            Just False ->
                                Decode.succeed <| NotStarring (Unstarred meta preview)

                            Nothing ->
                                if LoggedInUser.username loggedInUser == Author.username meta.author then
                                    Decode.succeed <| CantStar (Unstarrable meta preview)

                                else
                                    Decode.fail "Post is definitely authored by someone else but I encountered a missing or null `starred` field."
                }
    in
    Decode.succeed Tuple.pair
        |> optional "starred" (nullable Decode.bool) Nothing
        |> custom (metadataDecoder session)
        |> Decode.andThen postDecoder


fullDecoder : Session -> Decoder (Post Full)
fullDecoder session =
    let
        postDecoder ( isStarred, full, meta ) =
            Session.withLoggedInUser session
                { guest = Decode.succeed <| CantStar (Unstarrable meta full)
                , loggedIn =
                    \loggedInUser ->
                        case isStarred of
                            Just True ->
                                Decode.succeed <| Starring (Starred meta full)

                            Just False ->
                                Decode.succeed <| NotStarring (Unstarred meta full)

                            Nothing ->
                                if LoggedInUser.username loggedInUser == Author.username meta.author then
                                    Decode.succeed <| CantStar (Unstarrable meta full)

                                else
                                    Decode.fail "Post is definitely authored by someone else but I encountered a missing or null `starred` field."
                }
    in
    Decode.succeed (\a b c -> ( a, b, c ))
        |> optional "starred" (nullable Decode.bool) Nothing
        |> required "body" (Body.decoder |> Decode.map Full)
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
        |> required "createdAt" datetime
        |> optional "editedAt" (nullable datetime) Nothing
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
