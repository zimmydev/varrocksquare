module Session exposing (Session(..), authToken)

import Api exposing (AuthToken)
import Browser.Navigation as Nav
import LoggedInUser exposing (LoggedInUser)


type Session
    = Guest
    | LoggedIn LoggedInUser



-- Info on Session


authToken : Session -> Maybe AuthToken
authToken session =
    case session of
        Guest ->
            Nothing

        LoggedIn loggedInUser ->
            Just (LoggedInUser.authToken loggedInUser)
