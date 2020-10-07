module Profile exposing (Profile, avatar, bio, decoder, encode, joinDate)

import Avatar exposing (Avatar)
import Iso8601
import Json.Decode as Decode exposing (Decoder, nullable, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value, null)
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
    succeed Internals
        |> required "avatar" Avatar.decoder
        |> required "joinDate" Iso8601.decoder
        |> required "bio" (nullable string)
        |> Decode.map Profile


encode : Profile -> Value
encode (Profile prof) =
    let
        maybe encoder =
            Maybe.map encoder >> Maybe.withDefault null
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
