module UserTests exposing (..)

{-| This module tests the `User` module.
-}

import Avatar
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Profile
import Test exposing (..)
import User
import Username exposing (Username)


decodingTests : Test
decodingTests =
    let
        iso8601String =
            "2020-09-25T15:12:35.126Z"

        decodeUser =
            decodeValue User.decoder
    in
    describe "Decoding"
        [ describe "A valid JSON user" <|
            [ fuzz3 Fuzz.string Fuzz.string Fuzz.string "…when all fields present" <|
                \name href bio ->
                    [ ( "username", Encode.string name )
                    , ( "profile"
                      , Encode.object
                            [ ( "avatar", Encode.string href )
                            , ( "joinDate", Encode.string iso8601String )
                            , ( "bio", Encode.string bio )
                            ]
                      )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.all
                            [ Expect.ok
                            , Result.map User.username
                                >> Result.map Username.toString
                                >> Expect.equal (Ok name)
                            , Result.map User.profile
                                >> Expect.all
                                    [ Result.map Profile.avatar
                                        >> Result.map Avatar.href
                                        >> Expect.equal (Ok href)
                                    , Result.map Profile.bio
                                        >> Expect.equal (Ok (Just bio))
                                    ]
                            , Result.map User.avatar
                                >> Result.map Avatar.href
                                >> Expect.equal (Ok href)
                            ]
            , fuzz Fuzz.string "…when missing an avatar and a bio" <|
                \name ->
                    [ ( "username", Encode.string name )
                    , ( "profile", Encode.object [ ( "joinDate", Encode.string iso8601String ) ] )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.all
                            [ Expect.ok
                            , Result.map User.username
                                >> Result.map Username.toString
                                >> Expect.equal (Ok name)
                            , Result.map User.profile
                                >> Expect.all
                                    [ Result.map Profile.avatar
                                        >> Expect.equal (Ok Avatar.default)
                                    , Result.map Profile.bio
                                        >> Expect.equal (Ok Nothing)
                                    ]
                            , Result.map User.avatar
                                >> Expect.equal (Ok Avatar.default)
                            ]
            ]
        , describe "An invalid JSON user results in an error" <|
            let
                validProfile =
                    Encode.object [ ( "joinDate", Encode.string iso8601String ) ]
            in
            [ fuzz Fuzz.int "…when username field is mistyped" <|
                \x ->
                    [ ( "username", Encode.int x )
                    , ( "profile", validProfile )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz Fuzz.string "…when username field is mislabeled" <|
                \name ->
                    [ ( "name", Encode.string name )
                    , ( "profile", validProfile )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , test "…when username field is missing" <|
                \() ->
                    [ ( "profile", validProfile ) ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz Fuzz.string "…when profile field is missing" <|
                \name ->
                    [ ( "username", Encode.string name ) ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz Fuzz.string "…when profile object is totally empty" <|
                \name ->
                    [ ( "username", Encode.string name )
                    , ( "profile", Encode.object [] )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , test "…when user object is totally empty" <|
                \() ->
                    []
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            ]
        ]
