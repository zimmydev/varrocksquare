module Profile exposing (Profile, avatar, bio, debug, decoder)

import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder, field, nullable, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (optional, required)
import Time



-- TYPES


type
    Profile
    -- A Profile BELONGS TO a User
    = Profile Internals


type alias Internals =
    { avatar : Avatar
    , joinDate : Time.Posix
    , bio : Maybe String
    }



-- CREATION


decoder : Decoder Profile
decoder =
    Decode.succeed Internals
        |> optional "avatar" Avatar.decoder Avatar.default
        |> required "joinDate" datetime
        |> required "bio" (nullable string)
        |> Decode.map Profile



-- INFO


avatar : Profile -> Avatar
avatar (Profile prof) =
    prof.avatar


bio : Profile -> Maybe String
bio (Profile prof) =
    prof.bio



-- DEBUG


debug : Profile
debug =
    Profile
        { avatar = Avatar.debug
        , joinDate = Time.millisToPosix 0
        , bio = Just "I am an account meant for debugging purposes!"
        }
