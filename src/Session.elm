module Session exposing (Session, authToken, isGuest, navKey, new, viewer)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Browser.Navigation as Nav
import Inbox exposing (Inbox)
import Profile exposing (Profile)
import Username exposing (Username)
import Viewer exposing (Viewer)



-- TYPES


type Session
    = Guest Nav.Key
    | LoggedIn Nav.Key Viewer



-- INFO


isGuest : Session -> Bool
isGuest session =
    case session of
        Guest _ ->
            True

        LoggedIn _ _ ->
            False


navKey : Session -> Nav.Key
navKey session =
    case session of
        Guest key ->
            key

        LoggedIn key _ ->
            key


viewer : Session -> Maybe Viewer
viewer session =
    case session of
        Guest _ ->
            Nothing

        LoggedIn _ vwr ->
            Just vwr


authToken : Session -> Maybe AuthToken
authToken session =
    case session of
        Guest _ ->
            Nothing

        LoggedIn _ vwr ->
            Just (Viewer.authToken vwr)



-- CHANGES TO THE SESSION


new : Nav.Key -> Maybe Viewer -> Session
new key maybeViewer =
    case maybeViewer of
        Just vwr ->
            LoggedIn key vwr

        Nothing ->
            Guest key
