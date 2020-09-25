module Cache exposing (Cache, empty, retrieve, store)

{-| A `Cache` is a `Dict` with a `String` key, more or less.
-}

import Dict exposing (Dict)


type Cache value
    = Cache (Dict String (List value))



-- Obtaining a Cache


empty : Cache value
empty =
    Cache Dict.empty



-- Transforming a Cache


store : String -> List value -> Cache value -> Cache value
store key values (Cache dict) =
    dict
        |> Dict.update key
            (\mv ->
                case mv of
                    Nothing ->
                        Just values

                    Just oldValues ->
                        Just <| values ++ oldValues
            )
        |> Cache


retrieve : String -> Cache value -> Maybe (List value)
retrieve key (Cache dict) =
    dict |> Dict.get key
