module Profile exposing (Profile, avatar, bio, debug, decoder, joinDate)

import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder, nullable, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (optional, required)
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
        |> required "joinDate" datetime
        |> optional "bio" (nullable string) Nothing
        |> Decode.map Profile



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



-- Debugging a Profile


debug : Profile
debug =
    Profile
        { avatar = Avatar.debug
        , joinDate = Time.millisToPosix 0
        , bio = Just "I am an account meant for debugging purposes!"
        }
