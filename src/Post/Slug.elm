module Post.Slug exposing (Slug, debug, decoder, encode, toString, urlParser)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Parser exposing (Parser)


type Slug
    = Slug String



-- Obtaining a Slug


decoder : Decoder Slug
decoder =
    Decode.map Slug Decode.string


urlParser : Parser (Slug -> a) a
urlParser =
    Url.Parser.map Slug Url.Parser.string



-- Converting a Slug


encode : Slug -> Value
encode (Slug rawSlug) =
    Encode.string rawSlug


toString : Slug -> String
toString (Slug rawSlug) =
    rawSlug



-- Debugging a Slug


debug : String -> Slug
debug =
    Slug
