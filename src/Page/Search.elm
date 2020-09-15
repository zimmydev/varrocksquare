module Page.Search exposing (focusSearchbar, view)

import Browser.Dom as Dom
import Config.Elements as Elements
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Task



-- COMMANDS


focusSearchbar : msg -> Cmd msg
focusSearchbar focusedSearchbar =
    Task.attempt (always focusedSearchbar) (Dom.focus "searchbar")



-- VIEW


view : (String -> msg) -> String -> Element msg
view toMsg query =
    column Styles.page
        [ lazy2 searchbar toMsg query
        , if String.isEmpty query then
            none

          else
            el Styles.content (Elements.spinner [ centerX ])
        ]


searchbar : (String -> msg) -> String -> Element msg
searchbar toMsg query =
    let
        placeholder =
            Input.placeholder Styles.searchPlaceholder
                (text Strings.searchPlaceholder)
    in
    Input.text Styles.searchbar
        { onChange = toMsg
        , text = query |> Debug.log "Query"
        , placeholder = Just placeholder
        , label = Input.labelHidden "Searchbar"
        }
