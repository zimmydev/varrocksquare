module ProfileTests exposing (..)

{-| This module tests the `Profile` module.
-}

import Avatar
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (decodeValue)
import Json.Decode.Extra exposing (datetime)
import Json.Encode as Encode
import Profile exposing (Profile)
import Test exposing (..)



-- Decoding (TODO: Write testing for an invalid JSON profile)


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
            [ fuzz2 Fuzz.string Fuzz.string "…when all fields present" <|
                \href bio ->
                    [ ( "avatar", Encode.string href )
                    , ( "joinDate", Encode.string iso8601String )
                    , ( "bio", Encode.string bio )
                    ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.all
                            [ Expect.ok
                            , Result.map Profile.avatar
                                >> Result.map Avatar.href
                                >> Expect.equal (Ok href)
                            , Result.map Profile.bio
                                >> Expect.equal (Ok (Just bio))
                            ]
            , fuzz Fuzz.string "…when missing a bio" <|
                \href ->
                    [ ( "avatar", Encode.string href )
                    , ( "joinDate", Encode.string iso8601String )
                    ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.all
                            [ Expect.ok
                            , Result.map Profile.avatar
                                >> Result.map Avatar.href
                                >> Expect.equal (Ok href)
                            , Result.map Profile.bio
                                >> Expect.equal (Ok Nothing)
                            ]
            , fuzz Fuzz.string "…when missing an avatar" <|
                \bio ->
                    [ ( "joinDate", Encode.string iso8601String )
                    , ( "bio", Encode.string bio )
                    ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.all
                            [ Expect.ok
                            , Result.map Profile.avatar
                                >> Expect.equal (Ok Avatar.default)
                            , Result.map Profile.bio
                                >> Expect.equal (Ok (Just bio))
                            ]
            , test "…when missing an avatar and a bio" <|
                \() ->
                    [ ( "joinDate", Encode.string iso8601String ) ]
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.all
                            [ Expect.ok
                            , Result.map Profile.avatar
                                >> Expect.equal (Ok Avatar.default)
                            , Result.map Profile.bio
                                >> Expect.equal (Ok Nothing)
                            ]
            ]
        ]
