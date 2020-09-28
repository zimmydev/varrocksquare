module UserTests exposing (..)

{-| This module tests the `User` module.
-}

import Avatar
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, constant, oneOf, string, tuple)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Profile
import ProfileTests exposing (invalidIso8601, validIso8601)
import Test exposing (..)
import User
import Username exposing (Username)


decodingTests : Test
decodingTests =
    let
        decodeUser =
            decodeValue User.decoder

        smallProfile joinDate =
            Encode.object [ ( "joinDate", Encode.string joinDate ) ]
    in
    describe "Decoding" <|
        [ fuzz validData "A valid JSON user object" <|
            \( name, joinDate ) ->
                [ ( "username", Encode.string name )
                , ( "profile", smallProfile joinDate )
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
        , describe "An invalid JSON user object results in an error" <|
            [ fuzz invalidData "…when it contains invalid data" <|
                \( name, joinDate ) ->
                    [ ( "username", Encode.string name )
                    , ( "profile", smallProfile joinDate )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when username field is missing" <|
                \( _, joinDate ) ->
                    [ ( "profile", smallProfile joinDate ) ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when profile field is missing" <|
                \( name, _ ) ->
                    [ ( "username", Encode.string name ) ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when profile object is empty" <|
                \( name, _ ) ->
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



-- Fuzzers


validUsername : Fuzzer String
validUsername =
    string
        |> Fuzz.map ((++) "TestUser")


validData : Fuzzer ( String, String )
validData =
    tuple ( validUsername, validIso8601 )


invalidUsername : Fuzzer String
invalidUsername =
    constant ""


invalidData : Fuzzer ( String, String )
invalidData =
    oneOf
        [ tuple ( invalidUsername, validIso8601 )
        , tuple ( validUsername, invalidIso8601 )
        , tuple ( invalidUsername, invalidIso8601 )
        ]
