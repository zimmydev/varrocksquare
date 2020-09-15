module Api exposing (AuthToken, authHeader, debugToken, tokenDecoder)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)



-- AUTHTOKEN: TYPES


type AuthToken
    = AuthToken String



-- AUTHTOKEN: CREATE


tokenDecoder : Decoder AuthToken
tokenDecoder =
    Decode.succeed AuthToken
        |> required "token" Decode.string



-- AUTHTOKEN: TRANSFORM


authHeader : AuthToken -> Http.Header
authHeader (AuthToken tok) =
    Http.header "Authorization" ("Token " ++ tok)



-- DEBUG


debugToken : AuthToken
debugToken =
    AuthToken "DEBUG_TOKEN"
