module Session exposing (Session, authToken, avatar, debug, inbox, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Inbox exposing (Inbox)
import Username exposing (Username)



-- TYPES


type Session
    = Session Internals


type alias Internals =
    { authToken : AuthToken
    , username : Username
    , avatar : Avatar
    , inbox : Inbox
    }



-- INFO


authToken : Session -> AuthToken
authToken (Session sess) =
    sess.authToken


username : Session -> Username
username (Session sess) =
    sess.username


avatar : Session -> Avatar
avatar (Session sess) =
    sess.avatar


inbox : Session -> Inbox
inbox (Session sess) =
    sess.inbox



-- DEBUG


debug : Session
debug =
    Session
        { authToken = Api.debugToken
        , username = Username.debug "DebugUser"
        , avatar = Avatar.debug
        , inbox = Inbox.debug
        }
