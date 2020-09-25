module Page.Starred exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Post exposing (Post, Preview)



-- Model


type alias State =
    { starredPosts : ServerPosts }


type ServerPosts
    = NotAsked
    | Loading
    | Success (List (Post Preview))
    | Failure



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
    | PostResultsArrived (List (Post Preview))



-- Effects


type Effect
    = NoEffect



-- Init


init : () -> ( State, Effect )
init () =
    ( { starredPosts = NotAsked }
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

        PostResultsArrived _ ->
            -- TODO: Store the posts in the model.
            ignore



-- Views


view : State -> Page msg
view state =
    { navbarItem = Page.Starred
    , title = "Starred Posts"
    , body = lazy body state.starredPosts
    }


body : ServerPosts -> Element msg
body _ =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text "Starred Posts"
        ]
