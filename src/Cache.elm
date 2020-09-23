module Cache exposing (Cache, empty, retrieve, store)

import Dict exposing (Dict)


type Cache comparableKey value
    = Cache (Dict comparableKey value)



-- Obtaining a Cache


empty : Cache comparableKey value
empty =
    Cache Dict.empty



-- Transforming a Cache


store : comparableKey -> value -> Dict comparableKey value -> Dict comparableKey value
store =
    Dict.insert


retrieve : comparableKey -> Dict comparableKey value -> Maybe value
retrieve =
    Dict.get
