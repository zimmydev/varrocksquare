module Profile exposing (Profile, avatar, bio, decoder, encode, joinDate)

import Avatar exposing (Avatar)
import Iso8601
import Json.Decode as Decode exposing (Decoder, nullable, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Time


type Profile
    = Profile Internals


type alias Internals =
    -- Making the internals a record leaves it room to grow if necessary.
    { avatar : Avatar
    , joinDate : Time.Posix
    , bio : Maybe String
    }



-- Obtaining a Profile


decoder : Decoder Profile
decoder =
    Decode.succeed Internals
        |> optional "avatar" Avatar.decoder Avatar.default
        |> required "joinDate" Iso8601.decoder
        |> optional "bio" (nullable string) Nothing
        |> Decode.map Profile


encode : Profile -> Value
encode (Profile prof) =
    let
        maybe encoder =
            Maybe.map encoder >> Maybe.withDefault Encode.null
    in
    Encode.object
        [ ( "avatar", Avatar.encode prof.avatar )
        , ( "joinDate", Iso8601.encode prof.joinDate )
        , ( "bio", maybe Encode.string prof.bio )
        ]



-- Info on Profile


avatar : Profile -> Avatar
avatar (Profile prof) =
    prof.avatar


joinDate : Profile -> Time.Posix
joinDate (Profile prof) =
    prof.joinDate


bio : Profile -> Maybe String
bio (Profile prof) =
    prof.bio
