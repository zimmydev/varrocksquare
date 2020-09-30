module LoggedInUser exposing (LoggedInUser, authToken, avatar, decoder, encode, profile, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode exposing (Value)
import Profile exposing (Profile)
import User exposing (User)
import Username exposing (Username)


type LoggedInUser
    = LoggedInUser AuthToken User



-- Serializing a LoggedInUser


decoder : Decoder LoggedInUser
decoder =
    Decode.succeed LoggedInUser
        |> required "authToken" Api.tokenDecoder
        |> custom User.decoder


encode : LoggedInUser -> Value
encode user =
    Encode.object
        [ ( "authToken", Api.encodeToken <| authToken user )
        , ( "username", Username.encode <| username user )
        , ( "profile", Profile.encode <| profile user )
        ]



-- Info on LoggedInUser


authToken : LoggedInUser -> AuthToken
authToken (LoggedInUser token _) =
    token


username : LoggedInUser -> Username
username (LoggedInUser _ user) =
    User.username user


profile : LoggedInUser -> Profile
profile (LoggedInUser _ user) =
    User.profile user


avatar : LoggedInUser -> Avatar
avatar (LoggedInUser _ user) =
    User.avatar user
