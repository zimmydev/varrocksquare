module Config.Shortcuts exposing (get, map)

import Config.Links as Links exposing (Href)
import Dict exposing (Dict)


map : Dict String Href
map =
    Dict.fromList
        [ ( "Escape", Links.internal.home )
        , ( "F1", Links.internal.explore )
        , ( "F2", Links.internal.search )
        , ( "F3", Links.internal.tools )
        , ( "F4", Links.internal.settings )
        ]


get : String -> Href
get str =
    Dict.get str map
        |> Maybe.withDefault Links.internal.inert
