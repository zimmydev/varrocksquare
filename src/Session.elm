module Session exposing (Session, authToken, navKey, new, user)

import Api exposing (AuthToken)
import Browser.Navigation as Nav
import LoggedInUser exposing (LoggedInUser)


type Session
    = Guest Nav.Key
    | LoggedIn Nav.Key LoggedInUser



-- Obtaining a Session


new : Nav.Key -> Maybe LoggedInUser -> Session
new key maybeLoggedInUser =
    case maybeLoggedInUser of
        Nothing ->
            Guest key

        Just loggedInUser ->
            LoggedIn key loggedInUser



-- Info on Session


navKey : Session -> Nav.Key
navKey session =
    case session of
        Guest key ->
            key

        LoggedIn key _ ->
            key


user : Session -> Maybe LoggedInUser
user session =
    case session of
        Guest _ ->
            Nothing

        LoggedIn _ loggedInUser ->
            Just loggedInUser


authToken : Session -> Maybe AuthToken
authToken session =
    case session of
        Guest _ ->
            Nothing

        LoggedIn _ loggedInUser ->
            Just (LoggedInUser.authToken loggedInUser)
