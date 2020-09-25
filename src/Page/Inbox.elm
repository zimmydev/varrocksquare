module Page.Inbox exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Utils.String exposing (surround)



-- Model


type alias State =
    { messages : ServerMessages }


type ServerMessages
    = NotAsked
    | Loading
    | Success (List String)
    | Failure



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
    | MessageResultsArrived (List String)



-- Effects


type Effect
    = NoEffect



-- Init


init : () -> ( State, Effect )
init () =
    ( { messages = NotAsked }
    , NoEffect
    )


update : Msg parentMsg -> State -> ( State, Effect )
update msg state =
    let
        ignore =
            ( state, NoEffect )
    in
    case msg of
        ParentMsg parentMsg ->
            ignore

        MessageResultsArrived _ ->
            -- TODO: Store the messages in the model.
            ignore



-- Views


view : State -> Page msg
view state =
    { navbarItem = Page.Inbox
    , title = title state.messages
    , body = lazy body state.messages
    }


body : ServerMessages -> Element msg
body _ =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text "Inbox"
        ]



-- Helpers


title : ServerMessages -> String
title serverMessages =
    case serverMessages of
        NotAsked ->
            "Inbox"

        Loading ->
            "Inbox"

        Success messages ->
            messages
                |> List.length
                |> String.fromInt
                |> surround "("
                |> (++) "Inbox "

        Failure ->
            "Inbox"
