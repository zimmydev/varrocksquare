module Tests.Main exposing (..)

import Device
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, intRange, oneOf, tuple)
import Json.Encode as Encode exposing (Value)
import Main exposing (AppState, Effect, Global, Msg, NavigationConfig)
import Main.Flags as Flags exposing (Flags)
import ProgramTest exposing (ProgramDefinition, ProgramTest, SimulatedEffect)
import Random exposing (maxInt, minInt)
import Route
import SimulatedEffect.Cmd as CmdSim
import SimulatedEffect.Navigation as NavSim
import Test exposing (..)
import Test.Html.Selector as Selector



-- Program Test


startFullscreen : ProgramTest (AppState ()) Msg Effect
startFullscreen =
    -- Simulates a desktop device
    { size = ( 1280, 800 ) }
        |> Flags.encode
        |> startWith


startCompact : ProgramTest (AppState ()) Msg Effect
startCompact =
    -- Simulates a mobile device
    { size = ( 640, 1136 ) }
        |> Flags.encode
        |> startWith


startWith : Value -> ProgramTest (AppState ()) Msg Effect
startWith flags =
    let
        navigation =
            { key = ()
            , pushRoute = \() _ -> Cmd.none
            , replaceRoute = \() _ -> Cmd.none
            }
    in
    ProgramTest.createApplication
        { init = \json url () -> Main.init json url navigation
        , update = Main.update
        , onUrlRequest = Main.LinkClicked
        , onUrlChange = Route.routeUrl >> Main.RouteChanged
        , view = Main.view
        }
        |> ProgramTest.withSimulatedEffects simulate
        |> ProgramTest.withBaseUrl "https://vsq.app/"
        |> ProgramTest.start flags


simulate : Effect -> SimulatedEffect msg
simulate effect =
    let
        ignore =
            CmdSim.none
    in
    case effect of
        -- TODO: Cover more effect cases
        Main.Batch effects ->
            CmdSim.batch <|
                List.map simulate effects

        Main.PushRoute route ->
            route |> Route.toHref |> NavSim.pushUrl

        Main.ReplaceRoute route ->
            route |> Route.toHref |> NavSim.replaceUrl

        _ ->
            ignore



-- Tests


programTests : Test
programTests =
    describe "Program tests" <|
        [ describe "Initialization" <|
            [ describe "Flags are decoded as intended" <|
                [ fuzzWith { runs = 25 } validSize "Valid size brings user to homepage" <|
                    \( w, h ) ->
                        [ ( "size", intList [ w, h ] ) ]
                            |> Encode.object
                            |> startWith
                            |> expectHomePage
                , describe "Invalid size brings user to error page" <|
                    [ fuzzWith { runs = 75 } invalidSize "When one/more dimensions are invalid" <|
                        \( w, h ) ->
                            [ ( "size", intList [ w, h ] ) ]
                                |> Encode.object
                                |> startWith
                                |> expectErrorPage
                    , fuzzWith { runs = 25 } validDim "When size has too few dimension" <|
                        \w ->
                            [ ( "size", intList [ w ] ) ]
                                |> Encode.object
                                |> startWith
                                |> expectErrorPage
                    , fuzzWith { runs = 25 } validSize "When size has too many dimension" <|
                        \( w, h ) ->
                            [ ( "size", intList [ w, h, w ] ) ]
                                |> Encode.object
                                |> startWith
                                |> expectErrorPage
                    , test "When size has no dimensions" <|
                        \() ->
                            [ ( "size", intList [] ) ]
                                |> Encode.object
                                |> startWith
                                |> expectErrorPage
                    , test "When flags are totally empty" <|
                        \() ->
                            []
                                |> Encode.object
                                |> startWith
                                |> expectErrorPage
                    ]
                ]
            , describe "Size flags properly set the device profile" <|
                [ test "When fullscreen" <|
                    \() ->
                        startFullscreen
                            |> expectGlobal (.devpro >> Expect.equal Device.Full)
                , test "When compact" <|
                    \() ->
                        startCompact
                            |> expectGlobal (.devpro >> Expect.equal Device.Compact)
                ]
            ]
        , describe "Navigation" <|
            [ describe "Clicking the logo brings user to feeds page" <|
                [ test "When fullscreen" <|
                    \() ->
                        startFullscreen
                            |> ProgramTest.clickLink "Varrock Square" "/feeds"
                            |> ProgramTest.expectPageChange "https://vsq.app/feeds"
                , test "When compact" <|
                    \() ->
                        startCompact
                            |> ProgramTest.clickLink "VSq" "/feeds"
                            |> ProgramTest.expectPageChange "https://vsq.app/feeds"
                ]
            ]
        ]



-- Test Helpers


intList : List Int -> Value
intList =
    Encode.list Encode.int


expectErrorPage : ProgramTest state msg effect -> Expectation
expectErrorPage =
    expectPageSaying [ "There was a fatal application error" ]


expectHomePage : ProgramTest state msg effect -> Expectation
expectHomePage =
    expectPageSaying [ "Home" ]


expectPageSaying : List String -> ProgramTest state msg effect -> Expectation
expectPageSaying strings =
    ProgramTest.expectViewHas <|
        List.map Selector.text strings


expectGlobal : (Global () -> Expectation) -> ProgramTest (AppState ()) msg effect -> Expectation
expectGlobal expect =
    ProgramTest.expectModel (Main.globalOf >> expect)



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
