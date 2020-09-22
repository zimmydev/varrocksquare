module CommentId exposing (CommentId, decoder, toString)

import Json.Decode as Decode exposing (Decoder)


type CommentId
    = CommentId Int



-- Obtaining a CommentId


decoder : Decoder CommentId
decoder =
    Decode.map CommentId Decode.int



-- Converting a CommentId


toString : CommentId -> String
toString (CommentId id) =
    String.fromInt id
