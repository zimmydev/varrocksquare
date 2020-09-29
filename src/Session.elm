module Session exposing (Session, authToken, credentialed, new, user, withLoggedInUser)

import Api exposing (AuthToken)
import Browser.Navigation as Nav
import LoggedInUser exposing (LoggedInUser)


type Session
    = Guest
    | LoggedIn LoggedInUser



-- Obtaining a Session


new : Maybe LoggedInUser -> Session
new maybeLoggedInUser =
    case maybeLoggedInUser of
        Nothing ->
            Guest

        Just loggedInUser ->
            LoggedIn loggedInUser



-- Info on Session


user : Session -> Maybe LoggedInUser
user session =
    case session of
        Guest ->
            Nothing

        LoggedIn loggedInUser ->
            Just loggedInUser


authToken : Session -> Maybe AuthToken
authToken session =
    case session of
        Guest ->
            Nothing

        LoggedIn loggedInUser ->
            Just (LoggedInUser.authToken loggedInUser)



-- Tranforming a Session


credentialed : Session -> { loggedIn : a, guest : a } -> a
credentialed session { loggedIn, guest } =
    case session of
        Guest ->
            guest

        LoggedIn _ ->
            loggedIn


withLoggedInUser : Session -> { loggedIn : LoggedInUser -> a, guest : a } -> a
withLoggedInUser session { loggedIn, guest } =
    case session of
        Guest ->
            guest

        LoggedIn loggedInUser ->
            loggedIn loggedInUser
