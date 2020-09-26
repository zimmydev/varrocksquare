module ProfileTests exposing (..)

{-| This module tests the module `Profile`.
-}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (decodeValue)
import Json.Decode.Extra exposing (datetime)
import Json.Encode as Encode
import Profile exposing (Profile)
import Test exposing (..)



-- Decoding


decodingTests : Test
decodingTests =
    let
        decodeProfile =
            decodeValue Profile.decoder

        iso8601String =
            "2020-09-25T15:12:35.126Z"
    in
    describe "Decoding" <|
        [ describe "A valid JSON profile" <|
            [ fuzz2 Fuzz.string Fuzz.string "…with no missing fields" <|
                \href bio ->
                    [ ( "avatar", Encode.string href )
                    , ( "joinDate", Encode.string iso8601String )
                    , ( "bio", Encode.string bio )
                    ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.ok
            , fuzz Fuzz.string "…with a missing bio" <|
                \href ->
                    [ ( "avatar", Encode.string href )
                    , ( "joinDate", Encode.string iso8601String )
                    ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.ok
            , fuzz Fuzz.string "…with a missing avatar" <|
                \bio ->
                    [ ( "joinDate", Encode.string iso8601String )
                    , ( "bio", Encode.string bio )
                    ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.ok
            , test "…miss a missing avatar and bio" <|
                \() ->
                    [ ( "joinDate", Encode.string iso8601String ) ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.ok
            ]
        ]
