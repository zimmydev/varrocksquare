module LoggedInUser exposing (LoggedInUser, authToken, avatar, debug, decoder, profile, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Profile exposing (Profile)
import Username exposing (Username)


{-| The LoggedInUser type is meant to hang on to enough data to render your identity
in the navbar (Avatar and Username) and verify your identity with an AuthToken.
-}
type
    LoggedInUser
    -- AuthToken being at the end is an implem. detail to simplify decoding
    = LoggedInUser Username Profile AuthToken



-- Obtaining a LoggedInUser


decoder : Decoder (AuthToken -> LoggedInUser)
decoder =
    Decode.succeed LoggedInUser
        |> required "username" Username.decoder
        |> required "profile" Profile.decoder



-- Info on LoggedInUser


authToken : LoggedInUser -> AuthToken
authToken (LoggedInUser _ _ tok) =
    tok


username : LoggedInUser -> Username
username (LoggedInUser name _ _) =
    name


avatar : LoggedInUser -> Avatar
avatar (LoggedInUser _ prof _) =
    Profile.avatar prof


profile : LoggedInUser -> Profile
profile (LoggedInUser _ prof _) =
    prof



-- Debugging a LoggedInUser


debug : LoggedInUser
debug =
    LoggedInUser Username.debug Profile.debug Api.debugToken
