module Page.Help exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)



-- Model


type alias State =
    -- TODO: Make this useful
    ()



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg



-- Effects


type Effect
    = NoEffect



-- Init


init : State -> ( State, Effect )
init () =
    ( (), NoEffect )



-- Update


update : Msg parentMsg -> State -> ( State, Effect )
update msg () =
    let
        ignore =
            ( (), NoEffect )
    in
    case msg of
        ParentMsg _ ->
            ignore



-- Views


view : State -> Page msg
view () =
    { navbarItem = Page.Help
    , title = "Help"
    , body = lazy (\_ -> body) ()
    }


body : Element msg
body =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text "Help"
        ]
