module Api exposing (AuthToken, authHeader, debugToken, tokenDecoder)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type AuthToken
    = AuthToken String



-- Obtaining an AuthToken


tokenDecoder : Decoder AuthToken
tokenDecoder =
    Decode.succeed AuthToken
        |> required "token" Decode.string



-- Converting an AuthToken


authHeader : AuthToken -> Http.Header
authHeader (AuthToken tok) =
    Http.header "Authorization" ("Token " ++ tok)



-- Debugging an AuthToken


debugToken : AuthToken
debugToken =
    AuthToken "DEBUG_TOKEN"
