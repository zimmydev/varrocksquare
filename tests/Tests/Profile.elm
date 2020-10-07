module Tests.Profile exposing (..)

{-| This module tests the `Profile` module.
-}

import Avatar
import Expect
import Fuzz exposing (Fuzzer, constant, maybe, oneOf, string, tuple3)
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode exposing (Value)
import Profile
import Test exposing (..)
import TestUtils.Object as Object


type alias Href =
    String



-- Decoding


profile : Maybe Href -> String -> Maybe String -> Value
profile maybeHref joinDate maybeBio =
    Encode.object
        [ ( "avatar", maybeHref |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        , ( "joinDate", Encode.string joinDate )
        , ( "bio", maybeBio |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        ]


decodingTests : Test
decodingTests =
    let
        decodeProfile =
            decodeValue Profile.decoder
    in
    describe "Decoding" <|
        [ fuzz validData "A valid JSON profile object" <|
            \( maybeHref, joinDate, maybeBio ) ->
                profile maybeHref joinDate maybeBio
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
            [ fuzz invalidData "…when it contains invalid data" <|
                \( maybeHref, joinDate, maybeBio ) ->
                    profile maybeHref joinDate maybeBio
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
