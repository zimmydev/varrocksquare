module Cache exposing (Cache, empty, retrieve, store)

{-| A `Cache` is a `Dict` with a `String` key, more or less.
-}

import Dict exposing (Dict)


type Cache value
    = Cache (Dict String value)



-- Obtaining a Cache


empty : Cache value
empty =
    Cache Dict.empty



-- Transforming a Cache


store : String -> value -> Cache value -> Cache value
store key value (Cache dict) =
    dict |> Dict.insert key value |> Cache


retrieve : String -> Cache value -> Maybe value
retrieve key (Cache dict) =
    dict |> Dict.get key
