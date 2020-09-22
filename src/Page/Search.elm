module Page.Search exposing (focusSearchbar, view)

import Browser.Dom as Dom
import Config.Layout as Layout
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Task



-- Commands


focusSearchbar : msg -> Cmd msg
focusSearchbar focusedSearchbar =
    Task.attempt (always focusedSearchbar) (Dom.focus "searchbar")



-- Views


view : (String -> msg) -> String -> Page msg
view searchbarChanged query =
    { navbarItem = Page.Search
    , title = searchingString query
    , body = lazy2 body searchbarChanged query
    }


body : (String -> msg) -> String -> Element msg
body searchbarChanged query =
    column Styles.page
        [ lazy2 searchbar searchbarChanged query
        , if String.isEmpty query then
            none

          else
            el Styles.content
                (Layout.spinner [])
        ]


searchbar : (String -> msg) -> String -> Element msg
searchbar searchbarChanged query =
    let
        placeholder =
            Input.placeholder Styles.searchPlaceholder
                (text Strings.searchPlaceholder)
    in
    Input.text Styles.searchbar
        { onChange = searchbarChanged
        , text = query
        , placeholder = Just placeholder
        , label = Input.labelHidden "Searchbar"
        }



-- Helpers


searchingString : String -> String
searchingString query =
    if String.isEmpty query then
        "Searching…"

    else
        "Searching for '" ++ query ++ "'…"
