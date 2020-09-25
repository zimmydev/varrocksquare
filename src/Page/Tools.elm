module Page.Tools exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)



-- Model


type alias State =
    -- TODO: Make this useful
    { tool : Maybe Tool }


type
    Tool
    -- TODO: Create the actual tools, replacing dummy payloads
    = MaxHitCalc { x : Int }
    | CombatLevelCalc { x : Int }



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg



-- Effects


type Effect
    = NoEffect



-- Init


init : () -> ( State, Effect )
init () =
    ( { tool = Nothing }
    , NoEffect
    )



-- Update


update : Msg parentMsg -> State -> ( State, Effect )
update msg state =
    let
        ignore =
            ( state, NoEffect )
    in
    case msg of
        ParentMsg _ ->
            ignore



-- Views


view : State -> Page msg
view state =
    { navbarItem = Page.Tools
    , title = title state.tool
    , body = lazy body state.tool
    }


body : Maybe Tool -> Element msg
body tool =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text (title tool)
        ]



-- Helpers


title : Maybe Tool -> String
title maybeTool =
    case maybeTool of
        Just tool ->
            toolToString tool

        Nothing ->
            "Tools"


maxHitCalc : Tool
maxHitCalc =
    MaxHitCalc { x = 0 }


toolToString : Tool -> String
toolToString tool =
    case tool of
        MaxHitCalc _ ->
            "Max Hit Calculator"

        CombatLevelCalc _ ->
            "Combat Level Calculator"
