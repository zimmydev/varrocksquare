module MessageId exposing (MessageId, decoder, toString)

import Json.Decode as Decode exposing (Decoder)



-- TYPES


type MessageId
    = MessageId Int



-- CREATION


decoder : Decoder MessageId
decoder =
    Decode.map MessageId Decode.int



-- TRANSFORMATION


toString : MessageId -> String
toString (MessageId id) =
    String.fromInt id
