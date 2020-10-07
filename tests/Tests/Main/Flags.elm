module Tests.Main.Flags exposing (..)

{-| This module tests the module `Main.Flags`.
-}

import Avatar
import Device
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, intRange, oneOf, tuple)
import Json.Encode as Encode exposing (Value)
import LoggedInUser
import Main.Flags as Flags exposing (Flags)
import Profile
import Random exposing (maxInt, minInt)
import Test exposing (..)
import Tests.LoggedInUser exposing (loggedInUser)
import Tests.Profile exposing (profile)
import Username



-- Decoding


flags : List Int -> Value -> Value
flags dims user =
    Encode.object
        [ ( "size", Encode.list Encode.int dims )
        , ( "user", user )
        ]


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        [ describe "A valid JSON flags object" <|
            [ fuzz validData "…when no user is cached" <|
                \(( w, h ) as size) ->
                    flags [ w, h ] Encode.null
                        |> Flags.decode
                        |> Expect.all
                            [ Result.map .size
                                >> Expect.equal (Ok size)
                            , Result.map .user
                                >> Expect.equal (Ok Nothing)
                            ]
            , fuzzWith { runs = 1 } validData "…when some user is cached" <|
                let
                    ( token, name, joinDate ) =
                        ( "TEST_TOKEN", "TestUser93", "2020-09-25T15:12:35.333Z" )
                in
                \(( w, h ) as size) ->
                    flags [ w, h ] (loggedInUser token name (profile Nothing joinDate Nothing))
                        |> Flags.decode
                        |> Expect.all
                            [ Result.map .size
                                >> Expect.equal (Ok size)
                            , Result.map .user
                                >> Expect.ok
                            ]
            ]
        , describe "An invalid JSON flags object results in an error" <|
            [ fuzz invalidData "…when at least one device dimension is zero or negative" <|
                \( w, h ) ->
                    flags [ w, h ] Encode.null
                        |> Flags.decode
                        |> Expect.err
            , fuzz validData "…when too many device dimensions" <|
                \( w, h ) ->
                    flags [ w, h, w ] Encode.null
                        |> Flags.decode
                        |> Expect.err
            , fuzz validData "…when two few device dimensions" <|
                \( w, _ ) ->
                    flags [ w ] Encode.null
                        |> Flags.decode
                        |> Expect.err
            , test "…when no device dimensions" <|
                \() ->
                    flags [] Encode.null
                        |> Flags.decode
                        |> Expect.err
            , test "…when flags object is totally empty" <|
                \() ->
                    Encode.object []
                        |> Flags.decode
                        |> Expect.err
            ]
        ]



-- Fuzzers


validDim : Fuzzer Int
validDim =
    intRange 1 maxInt


validSize : Fuzzer Device.Size
validSize =
    tuple ( validDim, validDim )


invalidDim : Fuzzer Int
invalidDim =
    intRange minInt 0


invalidSize : Fuzzer Device.Size
invalidSize =
    oneOf
        [ tuple ( validDim, invalidDim )
        , tuple ( invalidDim, validDim )
        , tuple ( invalidDim, invalidDim )
        ]


validData : Fuzzer Device.Size
validData =
    validSize


invalidData : Fuzzer Device.Size
invalidData =
    invalidSize
