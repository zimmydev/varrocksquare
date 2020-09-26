module Main.FlagsTests exposing (..)

{-| This module tests the module `Main.Flags`.
-}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Encode as Encode
import Main.Flags as Flags exposing (Flags, decode)
import Test exposing (..)



-- Decoding


decodingTests : Test
decodingTests =
    let
        flagsObject { size } =
            Encode.object [ ( "size", Encode.object size ) ]
    in
    describe "Decoding" <|
        [ fuzz2 Fuzz.int Fuzz.int "A valid JSON flags object" <|
            \w h ->
                { size =
                    [ ( "width", Encode.int w )
                    , ( "height", Encode.int h )
                    ]
                }
                    |> flagsObject
                    |> Flags.decode
                    |> Expect.equal
                        (Ok { size = { width = w, height = h } })
        , describe "An invalid JSON flags object results in an error"
            [ fuzz2 Fuzz.int Fuzz.string "…when `size` object has a mistyped field" <|
                \w h ->
                    { size =
                        [ ( "width", Encode.int w )
                        , ( "height", Encode.string h )
                        ]
                    }
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , fuzz2 Fuzz.int Fuzz.int "…when `size` object has a mislabeled field" <|
                \w h ->
                    { size =
                        [ ( "x", Encode.int w )
                        , ( "height", Encode.int h )
                        ]
                    }
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , fuzz Fuzz.int "…when `size` object is missing a field" <|
                \w ->
                    { size =
                        [ ( "width", Encode.int w ) ]
                    }
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , test "…when `size` object is missing all its fields" <|
                \() ->
                    { size = [] }
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
