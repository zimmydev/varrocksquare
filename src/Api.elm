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
        |> Decode.andThen
            (\token ->
                if String.isEmpty token then
                    Decode.fail "Token cannot be empty"

                else
                    Decode.succeed <| AuthToken token
            )



-- Converting an AuthToken


authHeader : AuthToken -> Http.Header
authHeader (AuthToken tok) =
    Http.header "Authorization" ("Token " ++ tok)



-- Debugging an AuthToken


debugToken : AuthToken
debugToken =
    AuthToken "DEBUG_TOKEN"
