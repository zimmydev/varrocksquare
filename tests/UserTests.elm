module UserTests exposing (..)

{-| This module tests the `User` module.
-}

import Avatar
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, constant, oneOf, string, tuple)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Profile
import ProfileTests
import Test exposing (..)
import User
import Username exposing (Username)
import Utils.EncodeTesting exposing (missingFields)


decodingTests : Test
decodingTests =
    let
        iso8601String =
            "2020-09-25T15:12:35.126Z"

        decodeUser =
            decodeValue User.decoder
    in
    describe "Decoding"
        [ fuzz validData "A valid JSON user object" <|
            \( name, ( maybeHref, joinDate, maybeBio ) ) ->
                let
                    profile =
                        [ ( "avatar", Encode.string, maybeHref )
                        , ( "joinDate", Encode.string, Just joinDate )
                        , ( "bio", Encode.string, maybeBio )
                        ]
                            |> missingFields
                in
                [ ( "username", Encode.string name )
                , ( "profile", Encode.object profile )
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
                                    >> (case maybeHref of
                                            Just href ->
                                                Result.map Avatar.href
                                                    >> Expect.equal (Ok href)

                                            Nothing ->
                                                Expect.equal (Ok Avatar.default)
                                       )
                                , Result.map Profile.bio
                                    >> Expect.equal (Ok maybeBio)
                                ]
                        , Result.map User.avatar
                            >> (case maybeHref of
                                    Just href ->
                                        Result.map Avatar.href
                                            >> Expect.equal (Ok href)

                                    Nothing ->
                                        Expect.equal (Ok Avatar.default)
                               )
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



-- Fuzzers


validUsername : Fuzzer String
validUsername =
    string
        |> Fuzz.map ((++) "TestUser")


validData : Fuzzer ( String, ( Maybe String, String, Maybe String ) )
validData =
    tuple ( validUsername, ProfileTests.validData )


invalidUsername : Fuzzer String
invalidUsername =
    constant ""


invalidData : Fuzzer ( String, ( Maybe String, String, Maybe String ) )
invalidData =
    oneOf
        [ tuple ( validUsername, ProfileTests.invalidData )
        , tuple ( invalidUsername, ProfileTests.validData )
        , tuple ( invalidUsername, ProfileTests.invalidData )
        ]
