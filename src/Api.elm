module Api exposing (AuthToken, authHeader, authTokenDecoder, debugToken)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type AuthToken
    = AuthToken String



-- Obtaining an AuthToken


authTokenDecoder : Decoder AuthToken
authTokenDecoder =
    Decode.string
        |> Decode.map AuthToken



-- Converting an AuthToken


authHeader : AuthToken -> Http.Header
authHeader (AuthToken tok) =
    Http.header "Authorization" ("Token " ++ tok)



-- Debugging an AuthToken


debugToken : AuthToken
debugToken =
    AuthToken "DEBUG_TOKEN"
