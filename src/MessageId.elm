module MessageId exposing (MessageId, decoder, toString)

import Json.Decode as Decode exposing (Decoder)


type MessageId
    = MessageId Int



-- Obtaining a MessageId


decoder : Decoder MessageId
decoder =
    Decode.map MessageId Decode.int



-- Converting a MessageId


toString : MessageId -> String
toString (MessageId id) =
    String.fromInt id
