module Tests.LoggedInUser exposing (..)

{-| This module tests the `LoggedInUser` module.
-}

import Avatar
import Expect
import Fuzz exposing (Fuzzer, constant, oneOf, string, tuple)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode exposing (Value)
import LoggedInUser
import Profile
import Test exposing (..)
import Tests.Profile exposing (invalidIso8601, profile, validIso8601)
import Tests.User exposing (invalidUsername, validUsername)
import Username



-- Decoding


loggedInUser : String -> String -> Value -> Value
loggedInUser token name prof =
    Encode.object
        [ ( "authToken", Encode.string token )
        , ( "username", Encode.string name )
        , ( "profile", prof )
        ]


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        let
            decodeUser =
                decodeValue LoggedInUser.decoder
        in
        [ fuzz validData "A valid JSON logged-in user object" <|
            \( token, name, joinDate ) ->
                loggedInUser token name (profile Nothing joinDate Nothing)
                    |> decodeUser
                    |> Expect.all
                        [ Result.map LoggedInUser.username
                            >> Result.map Username.toString
                            >> Expect.equal (Ok name)
                        , Result.map LoggedInUser.authToken
                            >> Expect.ok
                        , Result.map LoggedInUser.profile
                            >> Expect.all
                                [ Result.map Profile.avatar
                                    >> Expect.equal (Ok Avatar.default)
                                , Result.map Profile.joinDate
                                    >> Expect.ok
                                , Result.map Profile.bio
                                    >> Expect.equal (Ok Nothing)
                                ]
                        , Result.map LoggedInUser.avatar
                            >> Expect.equal (Ok Avatar.default)
                        ]
        , describe "An invalid JSON logged-in user object results in an error" <|
            [ fuzz invalidData "…when it contains invalid data" <|
                \( token, name, joinDate ) ->
                    loggedInUser token name (profile Nothing joinDate Nothing)
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


validToken : Fuzzer String
validToken =
    string
        |> Fuzz.map ((++) "TestToken")


validData : Fuzzer ( String, String, String )
validData =
    tuple ( validToken, Tests.User.validData )
        |> Fuzz.map rejoin


invalidToken : Fuzzer String
invalidToken =
    constant ""


invalidData : Fuzzer ( String, String, String )
invalidData =
    oneOf
        [ tuple ( invalidToken, Tests.User.validData ) |> Fuzz.map rejoin
        , tuple ( validToken, Tests.User.invalidData ) |> Fuzz.map rejoin
        , tuple ( invalidToken, Tests.User.invalidData ) |> Fuzz.map rejoin
        ]



-- Fuzzer Helpers


rejoin : ( String, ( String, String ) ) -> ( String, String, String )
rejoin ( token, ( name, joinDate ) ) =
    ( token, name, joinDate )
