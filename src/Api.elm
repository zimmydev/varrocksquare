module Api exposing (AuthToken, authHeader, debug)

import Http



-- AUTHTOKEN: TYPES


type AuthToken
    = AuthToken String



-- AUTHTOKEN: CREATE
-- AUTHTOKEN: TRANSFORM


authHeader : AuthToken -> Http.Header
authHeader (AuthToken token) =
    Http.header "Authorization" ("Token " ++ token)



-- DEBUG


debug : AuthToken
debug =
    AuthToken "$DEBUGTOKENVALUE$"
