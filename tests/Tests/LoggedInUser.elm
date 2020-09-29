module Tests.LoggedInUser exposing (..)

{-| This module tests the `User` module.
-}

import Avatar
import Expect
import Fuzz exposing (Fuzzer, constant, oneOf, string, tuple)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import LoggedInUser
import Profile
import Test exposing (..)
import Tests.Profile exposing (invalidIso8601, validIso8601)
import Tests.User exposing (invalidUsername, validUsername)
import Username


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        let
            decodeUser =
                decodeValue LoggedInUser.decoder

            smallProfile joinDate =
                Encode.object [ ( "joinDate", Encode.string joinDate ) ]
        in
        [ fuzz validData "A valid JSON logged-in user object" <|
            \( name, token, joinDate ) ->
                [ ( "username", Encode.string name )
                , ( "authToken", Encode.string token )
                , ( "profile", smallProfile joinDate )
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
        , describe "An invalid JSON logged-in user object results in an error" <|
            [ fuzz invalidData "…when it contains invalid data" <|
                \( name, token, joinDate ) ->
                    [ ( "username", Encode.string name )
                    , ( "authToken", Encode.string token )
                    , ( "profile", smallProfile joinDate )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when username field is missing" <|
                \( _, token, joinDate ) ->
                    [ ( "authToken", Encode.string token )
                    , ( "profile", smallProfile joinDate )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when authToken field is missing" <|
                \( name, _, joinDate ) ->
                    [ ( "username", Encode.string name )
                    , ( "profile", smallProfile joinDate )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when profile field is missing" <|
                \( name, token, _ ) ->
                    [ ( "username", Encode.string name )
                    , ( "authToken", Encode.string token )
                    ]
                        |> Encode.object
                        |> decodeUser
                        |> Expect.err
            , fuzz validData "…when profile object is empty" <|
                \( name, token, _ ) ->
                    [ ( "username", Encode.string name )
                    , ( "authToken", Encode.string token )
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


validToken : Fuzzer String
validToken =
    string
        |> Fuzz.map ((++) "TestToken")


validData : Fuzzer ( String, String, String )
validData =
    tuple ( Tests.User.validData, validToken )
        |> Fuzz.map join


invalidToken : Fuzzer String
invalidToken =
    constant ""


invalidData : Fuzzer ( String, String, String )
invalidData =
    oneOf
        [ tuple ( Tests.User.validData, invalidToken )
            |> Fuzz.map join
        , tuple ( Tests.User.invalidData, validToken )
            |> Fuzz.map join
        , tuple ( Tests.User.invalidData, invalidToken )
            |> Fuzz.map join
        ]



-- Fuzzer Helpers


join : ( ( String, String ), String ) -> ( String, String, String )
join ( ( name, joinDate ), token ) =
    ( name, token, joinDate )
