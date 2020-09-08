module Viewer exposing (Viewer, avatar, debug, messages, token, username)

import Api exposing (AuthToken)
import Avatar exposing (Avatar)
import Username exposing (Username)



-- TYPES


type Viewer
    = Viewer AuthToken Username Avatar MessageCount


type alias MessageCount =
    Int



-- INFO


token : Viewer -> AuthToken
token (Viewer tok _ _ _) =
    tok


username : Viewer -> Username
username (Viewer _ un _ _) =
    un


avatar : Viewer -> Avatar
avatar (Viewer _ _ av _) =
    av


messages : Viewer -> Int
messages (Viewer _ _ _ mc) =
    mc



-- DEBUG


debug : Viewer
debug =
    Viewer Api.debug (Username.debug "DebugUser") Avatar.debug 69
