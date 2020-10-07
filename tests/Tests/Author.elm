module Tests.Author exposing (..)

import Author
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Test exposing (..)


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        [ test "A valid JSON author object" <|
            \() -> Expect.pass
        ]
