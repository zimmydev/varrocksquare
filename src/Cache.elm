module Cache exposing (Cache, empty, retrieve, store)

import Dict exposing (Dict)


type Cache comparableKey value
    = Cache (Dict comparableKey value)



-- Obtaining a Cache


empty : Cache comparableKey value
empty =
    Cache Dict.empty



-- Transforming a Cache


store : comparableKey -> value -> Cache comparableKey value -> Cache comparableKey value
store key value (Cache dict) =
    dict |> Dict.insert key value |> Cache


retrieve : comparableKey -> Cache comparableKey value -> Maybe value
retrieve key (Cache dict) =
    dict |> Dict.get key
