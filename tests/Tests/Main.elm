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
import Url.Builder



-- Program Test


fullscreen : List Int
fullscreen =
    [ 1280, 800 ]


compact : List Int
compact =
    [ 640, 1136 ]


start : List Int -> Maybe Value -> ProgramTest (AppState ()) Msg Effect
start dims maybeUser =
    startWith <|
        Encode.object
            [ ( "size", Encode.list Encode.int dims )
            , ( "user", maybeUser |> Maybe.withDefault Encode.null )
            ]


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
        |> ProgramTest.withBaseUrl (appUrl [] [])
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
                [ fuzz validSize "Valid size brings user to homepage" <|
                    \( w, h ) ->
                        start [ w, h ] Nothing
                            |> expectHomePage
                , describe "Invalid size brings user to error page" <|
                    [ fuzz invalidSize "When one/more dimensions are invalid" <|
                        \( w, h ) ->
                            start [ w, h ] Nothing
                                |> expectErrorPage
                    , fuzz validDim "When size has too few dimension" <|
                        \w ->
                            start [ w ] Nothing
                                |> expectErrorPage
                    , fuzz validSize "When size has too many dimension" <|
                        \( w, h ) ->
                            start [ w, h, w ] Nothing
                                |> expectErrorPage
                    , test "When size has no dimensions" <|
                        \() ->
                            start [] Nothing
                                |> expectErrorPage
                    , test "When flags are totally empty" <|
                        \() ->
                            Encode.object []
                                |> startWith
                                |> expectErrorPage
                    ]
                ]
            , describe "Size flags properly set the device profile" <|
                [ test "When fullscreen" <|
                    \() ->
                        start fullscreen Nothing
                            |> expectGlobal (.devpro >> Expect.equal Device.Full)
                , test "When compact" <|
                    \() ->
                        start compact Nothing
                            |> expectGlobal (.devpro >> Expect.equal Device.Compact)
                ]
            ]
        , describe "Navigation" <|
            [ describe "Clicking the logo brings user to feeds page" <|
                [ test "When fullscreen" <|
                    \() ->
                        start fullscreen Nothing
                            |> ProgramTest.clickLink "Varrock Square" "/feeds"
                            |> ProgramTest.expectPageChange (appUrl [ "feeds" ] [])
                , test "When compact" <|
                    \() ->
                        start compact Nothing
                            |> ProgramTest.clickLink "" "/feeds"
                            |> ProgramTest.expectPageChange (appUrl [ "feeds" ] [])
                ]
            ]
        ]



-- Test Helpers


appUrl : List String -> List Url.Builder.QueryParameter -> String
appUrl paths queries =
    Url.Builder.crossOrigin "https://varrocksquare.app" paths queries


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
