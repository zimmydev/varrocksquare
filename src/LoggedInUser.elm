module LoggedInUser exposing (LoggedInUser, authToken, avatar, debug, decoder, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Username exposing (Username)


{-| The LoggedInUser type is meant to hang on to enough data to render your identity
in the navbar (Avatar and Username) and verify your identity with an AuthToken.
-}
type
    LoggedInUser
    -- AuthToken being at the end is an implem. detail to simplify decoding
    = LoggedInUser Username Avatar AuthToken



-- Obtaining a LoggedInUser


decoder : Decoder (AuthToken -> LoggedInUser)
decoder =
    Decode.succeed LoggedInUser
        |> required "username" Username.decoder
        |> optional "avatar" Avatar.decoder Avatar.default



-- Info on LoggedInUser


username : LoggedInUser -> Username
username (LoggedInUser name _ _) =
    name


avatar : LoggedInUser -> Avatar
avatar (LoggedInUser _ av _) =
    av


authToken : LoggedInUser -> AuthToken
authToken (LoggedInUser _ _ tok) =
    tok



-- Debugging a LoggedInUser


debug : LoggedInUser
debug =
    LoggedInUser Username.debug Avatar.debug Api.debugToken
