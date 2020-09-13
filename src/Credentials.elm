module Credentials exposing (Credentials, authToken, debug, username)

import Api exposing (AuthToken)
import Username exposing (Username)



-- TYPES


type Credentials
    = Credentials Username AuthToken



-- INFO


username : Credentials -> Username
username (Credentials name _) =
    name


authToken : Credentials -> AuthToken
authToken (Credentials _ token) =
    token



-- DEBUG


debug : Credentials
debug =
    Credentials (Username.debug "zimmy") Api.debugToken
