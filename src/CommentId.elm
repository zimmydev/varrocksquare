module CommentId exposing (CommentId, decoder, toString)

import Json.Decode as Decode exposing (Decoder)



-- TYPES


type CommentId
    = CommentId Int



-- CREATION


decoder : Decoder CommentId
decoder =
    Decode.map CommentId Decode.int



-- TRANSFORMATION


toString : CommentId -> String
toString (CommentId id) =
    String.fromInt id
