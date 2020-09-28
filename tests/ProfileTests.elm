module ProfileTests exposing (..)

{-| This module tests the `Profile` module.
-}

import Avatar
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, constant, maybe, oneOf, string, tuple3)
import Json.Decode as Decode exposing (decodeValue)
import Json.Decode.Extra exposing (datetime)
import Json.Encode as Encode
import Profile exposing (Profile)
import Test exposing (..)
import Utils.EncodeTesting exposing (missingFields)



-- Decoding (TODO: Write testing for an invalid JSON profile)


decodingTests : Test
decodingTests =
    let
        decodeProfile =
            decodeValue Profile.decoder
    in
    describe "Decoding" <|
        [ fuzz validData "A valid JSON profile object" <|
            \( maybeHref, joinDate, maybeBio ) ->
                [ ( "avatar", Encode.string, maybeHref )
                , ( "joinDate", Encode.string, Just joinDate )
                , ( "bio", Encode.string, maybeBio )
                ]
                    |> missingFields
                    |> Encode.object
                    |> decodeProfile
                    |> Expect.all
                        [ Expect.ok
                        , Result.map Profile.avatar
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
        , describe "An invalid JSON profile object" <|
            [ fuzz invalidData "…when it has invalid data" <|
                \( maybeHref, joinDate, maybeBio ) ->
                    [ ( "avatar", Encode.string, maybeHref )
                    , ( "joinDate", Encode.string, Just joinDate )
                    , ( "bio", Encode.string, maybeBio )
                    ]
                        |> missingFields
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.err
            , fuzz validData "…when it is missing a joinDate" <|
                \( maybeHref, _, maybeBio ) ->
                    [ ( "avatar", Encode.string, maybeHref )
                    , ( "joinDate", Encode.string, Nothing )
                    , ( "bio", Encode.string, maybeBio )
                    ]
                        |> missingFields
                        |> Encode.object
                        |> decodeProfile
                        |> Expect.err
            ]
        ]



-- Fuzzers


validIso8601 : Fuzzer String
validIso8601 =
    oneOf <|
        List.map constant
            [ "2020-09-25T15:12:35.333Z"
            , "2020-09-25T15:12:35.333+02:30"
            , "2020-09-25T15:12:35.333"
            , "2020-09-25T15:12:35"
            , "2020-09-25"
            ]


validAvatar : Fuzzer (Maybe String)
validAvatar =
    maybe string


validBio : Fuzzer (Maybe String)
validBio =
    maybe string


validData : Fuzzer ( Maybe String, String, Maybe String )
validData =
    tuple3 ( validAvatar, validIso8601, validBio )


invalidIso8601 : Fuzzer String
invalidIso8601 =
    oneOf <|
        List.map constant
            [ "2019-01-01T00:00:00.000z" -- Invalid timezone designator
            , "2019-01-01t00:00:00.000Z" -- Invalid time delimiter
            , "2019-01-01T00-00-00.000Z" -- Delimiter formatting
            , "T00:00:00.000Z" -- Just the time
            , "2019/01/01" -- Invalid date
            , "Thursday" -- Totally nonsensical
            ]


invalidData : Fuzzer ( Maybe String, String, Maybe String )
invalidData =
    oneOf
        [ tuple3 ( validAvatar, invalidIso8601, validBio ) ]
