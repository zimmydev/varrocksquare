module Page.Search exposing (focusSearchbar, view)

import Browser.Dom as Dom
import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Task
import Ui



-- COMMANDS


focusSearchbar : msg -> Cmd msg
focusSearchbar focusedSearchbar =
    Task.attempt (always focusedSearchbar) (Dom.focus "searchbar")



-- VIEW


view : (String -> msg) -> Maybe String -> Element msg
view changeQuery maybeQuery =
    column Styles.page
        [ lazy2 viewSearchbar changeQuery maybeQuery
        , if maybeQuery /= Nothing then
            el Styles.content Ui.spinner

          else
            none
        ]


viewSearchbar : (String -> msg) -> Maybe String -> Element msg
viewSearchbar changeQuery maybeQuery =
    let
        placeholder =
            Input.placeholder Styles.searchPlaceholder
                (text Strings.searchPlaceholder)
    in
    Input.text Styles.searchbar
        { onChange = changeQuery
        , text = maybeQuery |> Maybe.withDefault ""
        , placeholder = Just placeholder
        , label = Input.labelHidden "Search Bar"
        }
