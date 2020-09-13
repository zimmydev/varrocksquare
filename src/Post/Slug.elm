module Post.Slug exposing (Slug, debug, decoder, encode, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)



-- TYPES


type Slug
    = Slug String



-- CREATION


decoder : Decoder Slug
decoder =
    Decode.map Slug Decode.string



-- TRANSFORMATION


encode : Slug -> Value
encode (Slug rawSlug) =
    Encode.string rawSlug


toString : Slug -> String
toString (Slug rawSlug) =
    rawSlug



-- URL PARSING


urlParser : Parser (Slug -> a) a
urlParser =
    Url.Parser.custom "SLUG"
        (Just << Slug)



-- DEBUG


debug : String -> Slug
debug =
    Slug
