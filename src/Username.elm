module Username exposing (Username, appAuthor, debug, decoder, encode, toPossessiveString, toString, urlParser, view)

import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder, fail, succeed)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)


type Username
    = Username String



-- Serializing a Username


decoder : Decoder Username
decoder =
    Decode.string
        |> Decode.andThen validate


validate : String -> Decoder Username
validate name =
    if String.isEmpty name then
        fail "Username should not be empty"

    else
        succeed (Username name)


urlParser : Parser (Username -> a) a
urlParser =
    Url.Parser.map Username Url.Parser.string


encode : Username -> Value
encode (Username name) =
    Encode.string name



-- Converting a Username


toString : Username -> String
toString (Username name) =
    name


toPossessiveString : Username -> String
toPossessiveString (Username name) =
    if String.right 1 name == "s" then
        name ++ "'"

    else
        name ++ "'s"


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
