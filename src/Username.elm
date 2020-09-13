module Username exposing (Username, debug, decoder, encode, toString, urlParser, view)

import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)



-- TYPES


type Username
    = Username String



-- CREATION


decoder : Decoder Username
decoder =
    Decode.map Username Decode.string



-- TRANSFORMATION


encode : Username -> Value
encode (Username raw) =
    Encode.string raw


toString : Username -> String
toString (Username raw) =
    raw


view : Username -> Element msg
view username =
    Element.text (toString username)



-- URL PARSING


urlParser : Parser (Username -> a) a
urlParser =
    Url.Parser.custom "USERNAME"
        (Just << Username)



-- DEBUG


debug : String -> Username
debug =
    Username
