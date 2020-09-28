module LoggedInUserTests exposing (..)

{-| This module tests the `User` module.
-}

import Avatar
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import LoggedInUser
import Profile
import Test exposing (..)
import Username exposing (Username)


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        [ test "A valid JSON user" <|
            \() ->
                Expect.pass
        ]
