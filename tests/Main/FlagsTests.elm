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
                    |> Expect.all
                        [ Expect.ok
                        , Result.map .size
                            >> Expect.all
                                [ Result.map .width
                                    >> Expect.equal (Ok w)
                                , Result.map .height
                                    >> Expect.equal (Ok h)
                                ]
                        ]
        , describe "An invalid JSON flags object results in an error"
            [ fuzz2 Fuzz.int Fuzz.string "…when size object has a mistyped height field" <|
                \w h ->
                    { size =
                        [ ( "width", Encode.int w )
                        , ( "height", Encode.string h )
                        ]
                    }
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , fuzz Fuzz.int "…when size object is missing a width field" <|
                \h ->
                    { size =
                        [ ( "height", Encode.int h ) ]
                    }
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , fuzz Fuzz.int "…when size object is missing a height field" <|
                \w ->
                    { size =
                        [ ( "width", Encode.int w ) ]
                    }
                        |> flagsObject
                        |> Flags.decode
                        |> Expect.err
            , test "…when size object is totally empty" <|
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
