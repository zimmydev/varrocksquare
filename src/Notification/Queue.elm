module Notification.Queue exposing (Queue, count, empty, isEmpty, push, remove, toList, view)

import Config.Styles as Styles
import Element exposing (Element)
import Notification exposing (Notification)



-- TYPES


type Queue
    = Queue (List Notification)



-- CREATION


empty : Queue
empty =
    Queue []



-- INFO


isEmpty : Queue -> Bool
isEmpty (Queue list) =
    List.isEmpty list


count : Queue -> Int
count (Queue notifs) =
    List.length notifs



-- TRANSFORM


push : Bool -> Notification -> Queue -> Queue
push enable notif (Queue notifs) =
    if enable || not (Notification.canSilence notif) then
        Queue (notif :: notifs)

    else
        Queue notifs


remove : Notification -> Queue -> Queue
remove notif (Queue notifs) =
    notifs
        |> List.filter (\n -> Notification.id notif /= Notification.id n)
        |> Queue


toList : Queue -> List Notification
toList (Queue notifs) =
    notifs


view : Queue -> Element msg
view queue =
    if isEmpty queue then
        Element.none

    else
        Element.column Styles.notificationArea
            (queue |> toList |> List.take 8 |> List.reverse |> List.map Notification.view)
