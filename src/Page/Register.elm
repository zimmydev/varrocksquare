module Page.Register exposing (Effect(..), Msg(..), State, init, update, view)

import Config.Styles as Styles
import Device
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import Page exposing (Page)



-- Model


type alias State =
    { fields : Fields }


type alias Fields =
    { email : String
    , username : String
    , password : String
    }



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg
    | EmailChanged String
    | UsernameChanged String
    | PasswordChanged String



-- Effects


type Effect
    = NoEffect



-- Init


init : () -> ( State, Effect )
init () =
    ( { fields =
            { email = ""
            , username = ""
            , password = ""
            }
      }
    , NoEffect
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

        EmailChanged email ->
            ( state |> updateEmail email
            , NoEffect
            )

        UsernameChanged username ->
            ( state |> updateUsername username
            , NoEffect
            )

        PasswordChanged password ->
            ( state |> updatePassword password
            , NoEffect
            )



-- Views


view : Device.Profile -> State -> Page (Msg parentMsg)
view devpro state =
    { navbarItem = Page.Register
    , title = "Registration"
    , body = lazy2 body devpro state
    }


body : Device.Profile -> State -> Element (Msg parentMsg)
body devpro state =
    Page.column
        [ form devpro state.fields ]


form : Device.Profile -> Fields -> Element (Msg parentMsg)
form devpro fields =
    Page.form
        { title = "Register"
        , devpro = devpro
        , forms =
            [ Page.inputField
                { onChange = EmailChanged
                , label = "Email"
                , placeholder = "Enter your email address…"
                , value = fields.email
                }
            , Page.inputField
                { onChange = UsernameChanged
                , label = "Username"
                , placeholder = "Enter your username…"
                , value = fields.username
                }
            , Page.inputField
                { onChange = PasswordChanged
                , label = "Password"
                , placeholder = "Enter your password…"
                , value = fields.password
                }
            ]
        }



-- Helpers


updateEmail : String -> State -> State
updateEmail email state =
    let
        fields =
            state.fields
    in
    { state | fields = { fields | email = email } }


updateUsername : String -> State -> State
updateUsername username state =
    let
        fields =
            state.fields
    in
    { state | fields = { fields | username = username } }


updatePassword : String -> State -> State
updatePassword password state =
    let
        fields =
            state.fields
    in
    { state | fields = { fields | password = password } }
