module Tag exposing (Tag, Unvalidated, Validated, decoder, new, toString, view)

import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)


type Tag validation
    = Tag String


type Unvalidated
    = Unvalidated


type Validated
    = Validated



-- Errors


type Error
    = IllegalCharacters (List Char)



-- Obtaining a Tag


new : String -> Tag Unvalidated
new string =
    Tag string


decoder : Decoder (Tag Validated)
decoder =
    Decode.string
        |> Decode.map Tag



-- Transforming a Tag


toString : Tag Validated -> String
toString (Tag string) =
    string


view : Tag Validated -> Element msg
view (Tag string) =
    Element.text <| "#" ++ string



-- Validating a Tag


validate : Tag Unvalidated -> Result Error (Tag Validated)
validate (Tag string) =
    let
        trimmed =
            String.trim string
    in
    case collectIllegalChars trimmed of
        [] ->
            Ok (Tag trimmed)

        chars ->
            Err <| IllegalCharacters chars



-- Validation Helpers


collectIllegalChars : String -> List Char
collectIllegalChars string =
    string
        |> String.foldl
            (\c acc ->
                if legalCategories |> List.any (\isLegal -> isLegal c) then
                    acc

                else
                    c :: acc
            )
            []


legalCategories : List (Char -> Bool)
legalCategories =
    [ Char.isAlphaNum
    , \c -> List.member c [ '.', '+', ':' ]
    ]
