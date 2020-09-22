module Session exposing (Session, authToken, isGuest, navKey, new, loggedInUser)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Browser.Navigation as Nav
import Inbox exposing (Inbox)
import Profile exposing (Profile)
import Username exposing (Username)
import LoggedInUser exposing (LoggedInUser)



-- TYPES


type Session
    = Guest Nav.Key
    | LoggedIn Nav.Key LoggedInUser



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


loggedInUser : Session -> Maybe LoggedInUser
loggedInUser session =
    case session of
        Guest _ ->
            Nothing

        LoggedIn _ user ->
            Just user


authToken : Session -> Maybe AuthToken
authToken session =
    case session of
        Guest _ ->
            Nothing

        LoggedIn _ user ->
            Just (LoggedInUser.authToken user)



-- CHANGES TO THE SESSION


new : Nav.Key -> Maybe LoggedInUser -> Session
new key maybeLoggedInUser =
    case maybeLoggedInUser of
        Just user ->
            LoggedIn key user

        Nothing ->
            Guest key
