module Main.Flags exposing (Flags, decode, decoder)

{-| This module houses all of the business logic associated with decoding flags
sent by JS to our elm app.
-}

import Device
import Json.Decode as Decode exposing (Decoder, decodeValue, nullable)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import LoggedInUser exposing (LoggedInUser)


type alias Flags =
    { size : Device.Size
    , user : Maybe LoggedInUser
    }



-- Serializing Flags


{-| Decode a JSON `Value` into a nice elm record called `Flags`.
-}
decode : Value -> Result Decode.Error Flags
decode json =
    decodeValue decoder json


{-| A `Flags` decoder.
-}
decoder : Decoder Flags
decoder =
    Decode.succeed Flags
        |> required "size" Device.decoder
        |> required "user" (nullable LoggedInUser.decoder)
