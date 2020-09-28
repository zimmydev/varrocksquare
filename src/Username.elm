module Username exposing (Username, appAuthor, debug, decoder, encode, toPossessiveString, toString, urlParser, view)

import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)


type Username
    = Username String



-- Obtaining a Username


decoder : Decoder Username
decoder =
    Decode.string
        |> Decode.andThen
            (\name ->
                if String.isEmpty name then
                    Decode.fail "Username cannot be empty"

                else
                    Decode.succeed <| Username name
            )


urlParser : Parser (Username -> a) a
urlParser =
    Url.Parser.map Username Url.Parser.string



-- Converting a Username


encode : Username -> Value
encode (Username raw) =
    Encode.string raw


toString : Username -> String
toString (Username raw) =
    raw


toPossessiveString : Username -> String
toPossessiveString (Username raw) =
    if String.right 1 raw == "s" then
        raw ++ "'"

    else
        raw ++ "'s"


view : Username -> Element msg
view username =
    Element.text (toString username)



-- Etc.


appAuthor : Username
appAuthor =
    -- An easter egg of sorts
    Username "TrustNoBanks"



-- Debugging a Username


debug : Username
debug =
    Username "DebugUser"
