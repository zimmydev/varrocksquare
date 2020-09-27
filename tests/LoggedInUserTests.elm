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
    let
        iso8601String =
            "2020-09-25T15:12:35.126Z"

        decodeUser =
            decodeValue LoggedInUser.decoder

        validProfile =
            Encode.object
                [ ( "joinDate", Encode.string iso8601String ) ]
    in
    describe "Decoding"
        [ describe "A valid JSON user" <|
            [ fuzz2 Fuzz.string Fuzz.string "…when missing an avatar and a bio" <|
                \name tok ->
                    [ ( "username", Encode.string name )
                    , ( "authToken", Encode.string tok )
                    , ( "profile", validProfile )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.all
                            [ Expect.ok
                            , Result.map LoggedInUser.username
                                >> Result.map Username.toString
                                >> Expect.equal (Ok name)
                            , Result.map LoggedInUser.profile
                                >> Expect.all
                                    [ Result.map Profile.avatar
                                        >> Expect.equal (Ok Avatar.default)
                                    , Result.map Profile.bio
                                        >> Expect.equal (Ok Nothing)
                                    ]
                            , Result.map LoggedInUser.avatar
                                >> Expect.equal (Ok Avatar.default)
                            ]
            , describe "An invalid JSON user results in an error" <|
                [ fuzz2 Fuzz.int Fuzz.string "…when username field is mistyped" <|
                    \name tok ->
                        [ ( "username", Encode.int name )
                        , ( "authToken", Encode.string tok )
                        , ( "profile", validProfile )
                        ]
                            |> Encode.object
                            |> decodeUser
                            |> Expect.err
                , fuzz2 Fuzz.string Fuzz.int "…when authToken field is mistyped" <|
                    \name tok ->
                        [ ( "username", Encode.string name )
                        , ( "authToken", Encode.int tok )
                        , ( "profile", validProfile )
                        ]
                            |> Encode.object
                            |> decodeUser
                            |> Expect.err
                , fuzz Fuzz.string "…when username field is missing" <|
                    \tok ->
                        [ ( "authToken", Encode.string tok )
                        , ( "profile", validProfile )
                        ]
                            |> Encode.object
                            |> decodeUser
                            |> Expect.err
                , fuzz Fuzz.string "…when authToken field is missing" <|
                    \name ->
                        [ ( "username", Encode.string name )
                        , ( "profile", validProfile )
                        ]
                            |> Encode.object
                            |> decodeUser
                            |> Expect.err
                , fuzz2 Fuzz.string Fuzz.string "…when profile field is missing" <|
                    \name tok ->
                        [ ( "username", Encode.string name )
                        , ( "authToken", Encode.string tok )
                        ]
                            |> Encode.object
                            |> decodeUser
                            |> Expect.err
                , fuzz2 Fuzz.string Fuzz.string "…when profile object is totally empty" <|
                    \name tok ->
                        [ ( "username", Encode.string name )
                        , ( "authToken", Encode.string tok )
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
        ]
