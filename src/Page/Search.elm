module Page.Search exposing (Effect(..), Msg(..), State, init, update, view)

import Browser.Dom as Dom
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Post exposing (Post, Preview)
import Task
import User exposing (User)
import Utils.String exposing (surround)



-- Model


type alias State =
    { query : Maybe String
    , postResults : ServerData (List (Post Preview))
    , userResults : ServerData (List User)
    }


type ServerData a
    = NotAsked
    | Loading String
    | Success a
    | Failure



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
      -- TODO: Add some kind of ResponseArrived variant
    | SearchbarChanged String
    | PostSearchResultsArrived (List (Post Preview))
    | UserSearchResultsArrived (List User)



-- Effects


type Effect
    = NoEffect
    | FocusSearchbar
    | ReplaceQuery (Maybe String)



-- Init


init : Maybe String -> ( State, Effect )
init query =
    ( { query = Nothing
      , postResults = NotAsked
      , userResults = NotAsked
      }
    , FocusSearchbar
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

        SearchbarChanged value ->
            let
                query =
                    if String.isEmpty value then
                        Nothing

                    else
                        Just value
            in
            {- TODO: If it's been a certain amount of time since the query has last changed, AND
               the query doesn't exist in our search cache, send the query off to the `searchUsers`
               and `searchPosts` API endpoints.
            -}
            ( { state | query = query }, NoEffect )

        PostSearchResultsArrived _ ->
            -- TODO: Cache the search results and place them in the model.
            ignore

        UserSearchResultsArrived _ ->
            -- TODO: Cache the search results and place them in the model.
            ignore



-- Views


view : State -> Page (Msg parentMsg)
view state =
    { navbarItem = Page.Search
    , title = title state.query
    , body = lazy body state.query
    }


body : Maybe String -> Element (Msg parentMsg)
body query =
    Page.column
        [ searchbar query
        , case query of
            Nothing ->
                none

            _ ->
                Page.content (Page.spinner [])
        ]


searchbar : Maybe String -> Element (Msg parentMsg)
searchbar query =
    Input.text Styles.searchbar
        { onChange = SearchbarChanged
        , text = query |> Maybe.withDefault ""
        , placeholder =
            Just <|
                Input.placeholder Styles.searchPlaceholder <|
                    text Strings.searchPlaceholder
        , label = Input.labelHidden "Searchbar"
        }



-- Helpers


title : Maybe String -> String
title maybeQuery =
    case maybeQuery of
        Nothing ->
            "Search"

        Just query ->
            "Searching for " ++ surround "'" query ++ "…"
