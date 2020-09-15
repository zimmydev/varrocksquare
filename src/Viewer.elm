module Viewer exposing (Viewer, authToken, avatar, debug, decoder, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Username exposing (Username)



-- TYPES


{-| The Viewer type is meant to hang on to enough data to render your identity
in the navbar (Avatar and Username) and verify your identity with an AuthToken.
-}
type
    Viewer
    -- AuthToken being at the end is an implem. detail to simplify decoding
    = Viewer Username Avatar AuthToken



-- CREATION


decoder : Decoder (AuthToken -> Viewer)
decoder =
    Decode.succeed Viewer
        |> required "username" Username.decoder
        |> optional "avatar" Avatar.decoder Avatar.default



-- INFO


authToken : Viewer -> AuthToken
authToken (Viewer _ _ tok) =
    tok


username : Viewer -> Username
username (Viewer name _ _) =
    name


avatar : Viewer -> Avatar
avatar (Viewer _ av _) =
    av



-- DEBUG


debug : Viewer
debug =
    Viewer
        (Username.debug "zimmy")
        Avatar.debug
        Api.debugToken
