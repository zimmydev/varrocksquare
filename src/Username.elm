module Username exposing (Username, appAuthor, debug, decoder, encode, toPossessiveString, toString, urlParser, view)

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


toPossessiveString : Username -> String
toPossessiveString (Username raw) =
    if String.right 1 raw == "s" then
        raw ++ "'"

    else
        raw ++ "'s"


view : Username -> Element msg
view username =
    Element.text (toString username)



-- URL PARSING


urlParser : Parser (Username -> a) a
urlParser =
    Url.Parser.map Username Url.Parser.string



-- ETC.


appAuthor : Username
appAuthor =
    -- An easter egg of sorts
    Username "TrustNoBanks"



-- DEBUG


debug : Username
debug =
    Username "DebugUser"
