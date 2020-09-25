module Page.Post exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Post exposing (Full, Post)
import Post.Slug as Slug exposing (Slug)


type alias State =
    { post : ServerPost }


type ServerPost
    = NotAsked
    | Loading Slug
    | Success Slug (Post Full)
    | Failure



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg



-- Effects


type Effect
    = NoEffect



-- Init


init : Slug -> ( State, Effect )
init slug =
    ( { post = NotAsked }
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
    { navbarItem = Page.Register
    , title = title state.post
    , body = lazy body state.post
    }


body : ServerPost -> Element msg
body post =
    column Styles.page
        [ el (Styles.contentHeader 1) <|
            text "Post"
        ]



-- Helpers


title : ServerPost -> String
title status =
    case status of
        Success _ post ->
            post
                |> Post.metadata
                |> .title

        NotAsked ->
            -- TODO: Ask the server for a post.
            "Post (NotAsked state!)"

        Loading slug ->
            "Loading " ++ Slug.toString slug ++ "…"

        Failure ->
            "Oops!"
