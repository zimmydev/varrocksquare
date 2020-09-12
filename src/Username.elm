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
    Decode.string
        |> Decode.map Username



-- TRANSFORMATION


encode : Username -> Value
encode (Username rawUsername) =
    Encode.string rawUsername


toString : Username -> String
toString (Username username) =
    username


view : Username -> Element msg
view (Username username) =
    Element.text username



-- URL PARSING


urlParser : Parser (Username -> a) a
urlParser =
    Url.Parser.custom "USERNAME"
        (Just << Username)



-- DEBUG


debug : String -> Username
debug =
    Username
