module Main.FlagsTests exposing (..)

{-| This module tests the module `Main.Flags`.
-}

import Device
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, intRange, tuple)
import Json.Encode as Encode exposing (Value)
import Main.Flags as Flags exposing (Flags, decode)
import Random exposing (maxInt)
import Test exposing (..)



-- Decoding


decodingTests : Test
decodingTests =
    describe "Decoding" <|
        [ fuzz validFlagsJson "A valid JSON flags object" <|
            \flags ->
                Flags.decode flags
                    |> Expect.ok
        , describe "An invalid JSON flags object results in an error" <|
            let
                flagsObject size =
                    Encode.object [ ( "size", Encode.object size ) ]
            in
            [ fuzz2 Fuzz.int Fuzz.string "…when size object has a mistyped height field" <|
                \w h ->
                    [ ( "width", Encode.int w )
                    , ( "height", Encode.string h )
                    ]
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , fuzz Fuzz.int "…when size object is missing a width field" <|
                \h ->
                    [ ( "height", Encode.int h ) ]
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , fuzz Fuzz.int "…when size object is missing a height field" <|
                \w ->
                    [ ( "width", Encode.int w ) ]
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , test "…when size object is totally empty" <|
                \() ->
                    []
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , test "…when the flags object is totally empty" <|
                \() ->
                    Encode.object []
                        |> Flags.decode
                        |> Expect.err
            ]
        ]



-- Fuzzers


validDeviceSize : Fuzzer Device.Size
validDeviceSize =
    let
        positiveNonzero =
            intRange 1 maxInt
    in
    tuple ( positiveNonzero, positiveNonzero )
        |> Fuzz.map (\( w, h ) -> { width = w, height = w })


validFlags : Fuzzer Flags
validFlags =
    validDeviceSize
        |> Fuzz.map (\size -> { size = size })


validFlagsJson : Fuzzer Value
validFlagsJson =
    validFlags
        |> Fuzz.map Flags.encode
