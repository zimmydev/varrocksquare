module Api exposing (AuthToken, authHeader, debugToken)

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


debugToken : AuthToken
debugToken =
    AuthToken "DEBUG_TOKEN"
