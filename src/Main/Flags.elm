module Main.Flags exposing (Flags, decode, default)

{-| This module houses all of the business logic associated with decoding flags
sent by JS to our elm app.
-}

import Device
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Decode.Pipeline exposing (required)
import Json.Encode exposing (Value)



-- TYPES


type alias Flags =
    { size : Device.Size }



-- SERIALIZATION


{-| Decode JSON flags into a nice elm data structure. Currently, in the case of
a decoding error, a set of reasonable defaults will be silently substituted.
-}
decode : Value -> Flags
decode json =
    json
        |> decodeValue decoder
        |> Result.withDefault default


decoder : Decoder Flags
decoder =
    Decode.succeed Flags
        |> required "size" Device.decoder



-- DEFAULTS


default : Flags
default =
    { size = Device.Size 1280 800 }
