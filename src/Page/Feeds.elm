module Page.Feeds exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Strings as Strings
import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)
import Utils.String exposing (abridge)



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
    { navbarItem = Page.Other
    , title = "Feeds"
    , body = lazy (\_ -> body) ()
    }


body : Element msg
body =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text "Feeds"
        , textColumn Styles.content <|
            [ paragraph (Styles.contentHeader 1) [ text "Some kind of post" ]
            , paragraph [ spacing 8 ] [ text (abridge 1500 Strings.loremIpsum) ]
            ]
        , textColumn Styles.content <|
            [ paragraph (Styles.contentHeader 1) [ text "Some kind of other post" ]
            , paragraph [ spacing 8 ] [ text (abridge 1500 Strings.loremIpsum) ]
            ]
        ]
