port module Api exposing (AuthToken, authHeader, debugToken, encodeToken, storeUser, tokenDecoder, userChanged)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)


type AuthToken
    = AuthToken String



-- Obtaining an AuthToken


tokenDecoder : Decoder AuthToken
tokenDecoder =
    Decode.string
        |> Decode.andThen
            (\token ->
                if String.isEmpty token then
                    Decode.fail "Token cannot be empty"

                else
                    Decode.succeed <| AuthToken token
            )


encodeToken : AuthToken -> Value
encodeToken (AuthToken token) =
    Encode.string token



-- Converting an AuthToken


authHeader : AuthToken -> Http.Header
authHeader (AuthToken token) =
    Http.header "Authorization" ("Token " ++ token)



-- Debugging an AuthToken


debugToken : AuthToken
debugToken =
    AuthToken "DEBUG_TOKEN"



-- Ports


port userChanged : (Maybe Value -> msg) -> Sub msg


port storeUser : Maybe Value -> Cmd msg
