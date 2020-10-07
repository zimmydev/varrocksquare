module Tests.User exposing (..)

{-| This module tests the `User` module.
-}

import Avatar
import Expect
import Fuzz exposing (Fuzzer, constant, oneOf, string, tuple)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode exposing (Value)
import Profile
import Test exposing (..)
import Tests.Profile exposing (invalidIso8601, profile, validIso8601)
import User
import Username exposing (Username)



-- Decoding


user : String -> Value -> Value
user name prof =
    Encode.object
        [ ( "username", Encode.string name )
        , ( "profile", prof )
        ]


decodingTests : Test
decodingTests =
    let
        decodeUser =
            decodeValue User.decoder
    in
    describe "Decoding" <|
        [ fuzz validData "A valid JSON user object" <|
            \( name, joinDate ) ->
                user name (profile Nothing joinDate Nothing)
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
                    user name (profile Nothing joinDate Nothing)
                        |> decodeUser
                        |> Expect.err
            , test "…when user object is totally empty" <|
                \() ->
                    Encode.object []
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
