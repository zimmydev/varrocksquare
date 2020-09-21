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



-- COMMANDS


focusSearchbar : msg -> Cmd msg
focusSearchbar focusedSearchbar =
    Task.attempt (always focusedSearchbar) (Dom.focus "searchbar")



-- VIEW


view : (String -> msg) -> String -> Page msg
view searchbarChanged query =
    let
        title =
            if String.isEmpty query then
                "Search"

            else
                "Searching for '" ++ query ++ "'"
    in
    { navbarItem = Page.Search
    , title = title
    , body =
        column Styles.page
            [ lazy2 searchbar searchbarChanged query
            , if String.isEmpty query then
                none

              else
                el Styles.content
                    (Layout.spinner [ centerX ])
            ]
    }


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
