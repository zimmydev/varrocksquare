module Utils.EncodeTesting exposing (..)

import Json.Encode as Encode exposing (Value)


missingFields : List ( String, a -> Value, Maybe a ) -> List ( String, Value )
missingFields list =
    list
        |> List.foldl
            (\( key, encode, maybeValue ) acc ->
                case maybeValue of
                    Just value ->
                        ( key, encode value ) :: acc

                    Nothing ->
                        acc
            )
            []
