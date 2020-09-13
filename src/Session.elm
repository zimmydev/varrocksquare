module Session exposing (Session(..), avatar, credentials, debug, displayName, inbox, isGuest, navKey, profile)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Browser.Navigation as Nav
import Credentials exposing (Credentials)
import Inbox exposing (Inbox)
import Profile exposing (Profile)
import Username exposing (Username)



-- TYPES


type Session
    = Guest Nav.Key
    | LoggedIn Nav.Key Credentials Profile Inbox



-- INFO


isGuest : Session -> Bool
isGuest sess =
    case sess of
        Guest _ ->
            True

        LoggedIn _ _ _ _ ->
            False


navKey : Session -> Nav.Key
navKey sess =
    case sess of
        Guest key ->
            key

        LoggedIn key _ _ _ ->
            key


credentials : Session -> Maybe Credentials
credentials sess =
    case sess of
        Guest _ ->
            Nothing

        LoggedIn _ cred _ _ ->
            Just cred


profile : Session -> Maybe Profile
profile sess =
    case sess of
        Guest _ ->
            Nothing

        LoggedIn _ _ prof _ ->
            Just prof


displayName : Session -> String
displayName sess =
    case sess of
        Guest _ ->
            "Guest"

        LoggedIn _ cred _ _ ->
            cred
                |> Credentials.username
                |> Username.toString
                |> (++) "@"


avatar : Session -> Avatar
avatar sess =
    case sess of
        Guest _ ->
            Avatar.default

        LoggedIn _ _ prof _ ->
            Profile.avatar prof


inbox : Session -> Maybe Inbox
inbox sess =
    case sess of
        Guest _ ->
            Nothing

        LoggedIn _ _ _ inb ->
            Just inb



-- DEBUG


debug : Nav.Key -> Session
debug key =
    LoggedIn key
        Credentials.debug
        Profile.debug
        Inbox.debug
