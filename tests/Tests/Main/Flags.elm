module Tests.Main.Flags exposing (..)

{-| This module tests the module `Main.Flags`.
-}

import Device
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, intRange, oneOf, tuple)
import Json.Encode as Encode exposing (Value)
import Main.Flags as Flags exposing (Flags)
import Random exposing (maxInt, minInt)
import Test exposing (..)



-- Decoding


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        [ fuzz validData "A valid JSON flags object" <|
            \(( w, h ) as size) ->
                [ ( "size", Encode.list Encode.int [ w, h ] ) ]
                    |> Encode.object
                    |> Flags.decode
                    |> Expect.all
                        [ Result.map .size
                            >> Expect.equal (Ok size)
                        ]
        , describe "An invalid JSON flags object results in an error" <|
            [ fuzz invalidData "…when at least one device dimension is zero or negative" <|
                \( w, h ) ->
                    [ ( "size", Encode.list Encode.int [ w, h ] ) ]
                        |> Encode.object
                        |> Flags.decode
                        |> Expect.err
            , fuzz2 validData validDim "…when too many device dimensions" <|
                \( w, h ) x ->
                    [ ( "size", Encode.list Encode.int [ w, h, x ] ) ]
                        |> Encode.object
                        |> Flags.decode
                        |> Expect.err
            , fuzz validData "…when two few device dimensions" <|
                \( w, _ ) ->
                    [ ( "size", Encode.list Encode.int [ w ] ) ]
                        |> Encode.object
                        |> Flags.decode
                        |> Expect.err
            , test "…when no device dimensions" <|
                \() ->
                    [ ( "size", Encode.list Encode.int [] ) ]
                        |> Encode.object
                        |> Flags.decode
                        |> Expect.err
            , test "…when flags object is totally empty" <|
                \() ->
                    []
                        |> Encode.object
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
