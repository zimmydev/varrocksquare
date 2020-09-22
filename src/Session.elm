module Session exposing (Session, authToken, credentialed, navKey, new, user, withLoggedInUser)

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



-- Tranforming a Session


credentialed : Session -> { loggedIn : a, guest : a } -> a
credentialed session { loggedIn, guest } =
    case session of
        Guest _ ->
            guest

        LoggedIn _ _ ->
            loggedIn


withLoggedInUser : Session -> { loggedIn : LoggedInUser -> a, guest : a } -> a
withLoggedInUser session { loggedIn, guest } =
    case session of
        Guest _ ->
            guest

        LoggedIn _ loggedInUser ->
            loggedIn loggedInUser
