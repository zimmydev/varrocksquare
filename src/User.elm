module User exposing (User, avatar, decoder, profile, username)

import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Profile exposing (Profile)
import Username exposing (Username)


type User
    = User Username Profile



-- Obtaining a User


decoder : Decoder User
decoder =
    Decode.succeed User
        |> required "username" Username.decoder
        |> required "profile" Profile.decoder



-- Info on User


username : User -> Username
username (User name _) =
    name


profile : User -> Profile
profile (User _ prof) =
    prof


avatar : User -> Avatar
avatar user =
    profile user
        |> Profile.avatar
