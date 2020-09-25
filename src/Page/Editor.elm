module Page.Editor exposing (Effect(..), Msg(..), State, init, isCreating, update, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Post exposing (Full, Post)
import Post.Slug as Slug exposing (Slug)


type alias State =
    { status : Status }


type Status
    = Creating PostTitle Markdown Tags
    | Editing ServerPost


type alias PostTitle =
    String


type alias Markdown =
    String


type alias Tags =
    String


type ServerPost
    = NotAsked
    | Loading Slug
    | Success Slug PostTitle Markdown Tags
    | Failure



-- Info on Editor State


isCreating : State -> Bool
isCreating { status } =
    case status of
        Creating _ _ _ ->
            True

        Editing _ ->
            False



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
    | EditorChanged Markdown



-- Effects


type Effect
    = NoEffect



-- Init


init : Maybe Slug -> ( State, Effect )
init maybeSlug =
    case maybeSlug of
        Nothing ->
            ( { status = Creating "" "" "" }, NoEffect )

        Just slug ->
            -- TODO: Fire off a request for the post with this slug.
            ( { status = Editing NotAsked }, NoEffect )



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

        EditorChanged md ->
            let
                newStatus =
                    case state.status of
                        Creating ttl _ tgs ->
                            Creating ttl md tgs

                        Editing (Success slg ttl _ tgs) ->
                            Editing (Success slg ttl md tgs)

                        other ->
                            other
            in
            ( { state | status = newStatus }, NoEffect )



-- Views


view : State -> Page msg
view state =
    { navbarItem = Page.Register
    , title = title state.status
    , body = lazy body state.status
    }


body : Status -> Element msg
body status =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text "Editor"
        ]



-- Helpers


title : Status -> String
title status =
    case status of
        Creating ttl _ _ ->
            "New Post"

        Editing NotAsked ->
            -- TODO: Ask the server for a post.
            "Editing (NotAsked state!)"

        Editing (Loading slug) ->
            "Loading " ++ Slug.toString slug ++ "…"

        Editing (Success slug _ _ _) ->
            -- TODO: A more descriptive title (slugs aren't as readable as post titles)
            "Editing " ++ Slug.toString slug ++ "…"

        Editing Failure ->
            "Oops!"
