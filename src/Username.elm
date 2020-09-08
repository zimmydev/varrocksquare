module Username exposing (Username, debug, decoder, encode, view, toString, urlParser)

import Element exposing (Element, text)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)



-- TYPES


type Username
    = Username String



-- CREATE


decoder : Decoder Username
decoder =
    Decode.map Username Decode.string



-- TRANSFORM


encode : Username -> Value
encode (Username username) =
    Encode.string username


toString : Username -> String
toString (Username username) =
    username


view : Username -> Element msg
view (Username username) =
    text username


urlParser : Parser (Username -> a) a
urlParser =
    Url.Parser.custom "USERNAME"
        (Just << Username)



-- DEBUG


debug : String -> Username
debug =
    Username
