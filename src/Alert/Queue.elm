module Alert.Queue exposing (Queue, count, empty, isEmpty, push, remove, toList, view)

{-| TODO: Convert to use a dictionary implementation.
-}

import Alert exposing (Alert)
import Config.Styles as Styles
import Element exposing (Element)



-- TYPES


type Queue
    = Queue (List Alert)



-- CREATION


empty : Queue
empty =
    Queue []



-- INFO


isEmpty : Queue -> Bool
isEmpty (Queue alerts) =
    List.isEmpty alerts


count : Queue -> Int
count (Queue alerts) =
    List.length alerts



-- TRANSFORMATION


push : Alert -> Queue -> Queue
push alert (Queue alerts) =
    Queue (alert :: alerts)


remove : Alert -> Queue -> Queue
remove alert (Queue alerts) =
    alerts
        |> List.filter (\n -> Alert.id alert /= Alert.id n)
        |> Queue


toList : Queue -> List Alert
toList (Queue alerts) =
    alerts


view : Queue -> Element msg
view queue =
    if isEmpty queue then
        Element.none

    else
        Element.column Styles.alertArea
            (queue |> toList |> List.take 5 |> List.reverse |> List.map Alert.view)
