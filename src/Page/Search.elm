module Page.Search exposing (focusSearchbar, view)

import Browser.Dom as Dom
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Task



-- TODO: Upgrade Search page with its own update function
-- Commands


focusSearchbar : msg -> Cmd msg
focusSearchbar focusedSearchbar =
    Task.attempt (always focusedSearchbar) (Dom.focus "searchbar")



-- Views


view : (String -> msg) -> Maybe String -> Page msg
view searchbarChanged maybeQuery =
    { navbarItem = Page.Search
    , title = searchingString maybeQuery
    , body = lazy2 body searchbarChanged maybeQuery
    }


body : (String -> msg) -> Maybe String -> Element msg
body searchbarChanged maybeQuery =
    column Styles.page
        [ lazy2 searchbar searchbarChanged maybeQuery
        , case maybeQuery of
            Nothing ->
                none

            _ ->
                el Styles.content <|
                    Page.spinner []
        ]


searchbar : (String -> msg) -> Maybe String -> Element msg
searchbar searchbarChanged maybeQuery =
    let
        placeholder =
            Input.placeholder Styles.searchPlaceholder
                (text Strings.searchPlaceholder)
    in
    Input.text Styles.searchbar
        { onChange = searchbarChanged
        , text = maybeQuery |> Maybe.withDefault ""
        , placeholder = Just placeholder
        , label = Input.labelHidden "Searchbar"
        }



-- Helpers


searchingString : Maybe String -> String
searchingString maybeQuery =
    case maybeQuery of
        Nothing ->
            "Search"

        Just query ->
            "Searching for '" ++ query ++ "'…"
