module Tests.Post exposing (..)

import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Post
import Session
import Test exposing (..)


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        [ test "Stub" <|
            \() -> Expect.pass
        ]
