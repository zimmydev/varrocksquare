module MainTest exposing (..)

{-| This module tests the module `Main` and `Main.Flags`.
-}

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Encode as Encode
import Main exposing (Model)
import Main.Flags as Flags exposing (Flags, decode, default)
import Test exposing (..)



-- Main.Flags


flagsTest : Test
flagsTest =
    describe "Main.Flags" <|
        [ describe "Defaults are reasonable" <|
            [ test "Screen size" <|
                \() ->
                    Flags.default.size.width
                        |> Expect.greaterThan 1180
            ]
        , describe "Decoding" <|
            let
                validFlags w h =
                    Encode.object
                        [ ( "size"
                          , Encode.object
                                [ ( "width", Encode.int w )
                                , ( "height", Encode.int h )
                                ]
                          )
                        ]

                mistypedSize w h =
                    Encode.object
                        [ ( "size"
                          , Encode.object
                                [ ( "width", Encode.string w )
                                , ( "height", Encode.string h )
                                ]
                          )
                        ]
            in
            [ fuzz2 Fuzz.int Fuzz.int "Passing a valid JSON flags object" <|
                \w h ->
                    validFlags w h
                        |> Flags.decode
                        |> Expect.equal
                            { size = { width = w, height = h } }
            , describe "Passing a misshapen JSON flags object results in the defaults"
                [ fuzz2 Fuzz.string Fuzz.string "Wrong types" <|
                    \w h ->
                        mistypedSize w h
                            |> Flags.decode
                            |> Expect.equal Flags.default
                , test "Empty object" <|
                    \() ->
                        Encode.object []
                            |> Flags.decode
                            |> Expect.equal Flags.default
                , test "Size object is missing its fields" <|
                    \() ->
                        Encode.object [ ( "size", Encode.object [] ) ]
                            |> Flags.decode
                            |> Expect.equal Flags.default
                ]
            ]
        ]
