module LoggedInUser exposing (LoggedInUser, authToken, avatar, debug, decoder, profile, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Profile exposing (Profile)
import User exposing (User)
import Username exposing (Username)


{-| The LoggedInUser type is meant to hang on to enough data to render your identity
in the navbar (Avatar and Username) and verify your identity with an AuthToken.
-}
type
    LoggedInUser
    -- AuthToken being at the end is an implem. detail to simplify decoding
    = LoggedInUser User AuthToken



-- Obtaining a LoggedInUser


decoder : Decoder (AuthToken -> LoggedInUser)
decoder =
    Decode.succeed LoggedInUser
        |> required "user" User.decoder



-- Info on LoggedInUser


authToken : LoggedInUser -> AuthToken
authToken (LoggedInUser _ tok) =
    tok


username : LoggedInUser -> Username
username loggedInUser =
    user loggedInUser
        |> User.username


profile : LoggedInUser -> Profile
profile loggedInUser =
    user loggedInUser
        |> User.profile


avatar : LoggedInUser -> Avatar
avatar loggedInUser =
    user loggedInUser
        |> User.avatar



-- Helpers


user : LoggedInUser -> User
user (LoggedInUser usr _) =
    usr



-- Debugging a LoggedInUser


debug : LoggedInUser
debug =
    LoggedInUser User.debug Api.debugToken
