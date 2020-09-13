module Profile exposing (Profile, avatar, bio, decoder)

import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder, field, nullable, string)
import Json.Decode.Extra as DecodeExtra
import Time



-- TYPES


type Profile
    = Profile Internals


type alias Internals =
    { avatar : Avatar
    , joinDate : Time.Posix
    , bio : Maybe String
    }



-- CREATION


decoder : Decoder Profile
decoder =
    Decode.map3 Internals
        (field "avatar" Avatar.decoder)
        (field "joinDate" DecodeExtra.datetime)
        (field "bio" (nullable string))
        |> Decode.map Profile



-- INFO


avatar : Profile -> Avatar
avatar (Profile prof) =
    prof.avatar


bio : Profile -> Maybe String
bio (Profile prof) =
    prof.bio
