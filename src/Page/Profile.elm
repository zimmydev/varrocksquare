module Page.Profile exposing (Effect(..), Msg(..), State, init, update, username, view)

import Config.Styles as Styles
import Element exposing (..)
import Element.Input as Input
import Element.Lazy exposing (..)
import LoggedInUser exposing (LoggedInUser)
import Page exposing (Page)
import Session exposing (Session(..))
import User exposing (User)
import Username exposing (Username)



-- Model


type alias State =
    { profile : ProfileStatus }


type ProfileStatus
    = ViewingMe LoggedInUser
    | ViewingOther ServerUser


type ServerUser
    = NotAsked Username
    | Loading Username
    | Success User
    | Failed Username



-- Info


username : State -> Username
username { profile } =
    case profile of
        ViewingMe loggedInUser ->
            LoggedInUser.username loggedInUser

        ViewingOther (Success user) ->
            User.username user

        ViewingOther (NotAsked name) ->
            name

        ViewingOther (Loading name) ->
            name

        ViewingOther (Failed name) ->
            name



-- Messages


type Msg parentMsg
    = ParentMsg parentMsg



-- Effects


type Effect
    = NoEffect



-- Init


init : Session -> Username -> ( State, Effect )
init session name =
    case session of
        Guest ->
            ( { profile = ViewingOther (NotAsked name) }, NoEffect )

        LoggedIn loggedInUser ->
            if LoggedInUser.username loggedInUser == name then
                ( { profile = ViewingMe loggedInUser }, NoEffect )

            else
                ( { profile = ViewingOther (NotAsked name) }, NoEffect )



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



-- Views


view : State -> Page msg
view state =
    { navbarItem = Page.Profile
    , title = title state.profile
    , body = lazy body state.profile
    }


body : ProfileStatus -> Element msg
body status =
    Page.column
        [ Page.content <|
            el (Styles.contentHeader 1) <|
                text (title status)
        ]



-- Helpers


title : ProfileStatus -> String
title status =
    let
        profileString name =
            name
                |> Username.toPossessiveString
                |> (\s -> s ++ " Profile")
    in
    case status of
        ViewingMe loggedInUser ->
            loggedInUser
                |> LoggedInUser.username
                |> profileString

        ViewingOther (Success user) ->
            user
                |> User.username
                |> profileString

        ViewingOther (NotAsked name) ->
            -- TODO: Ask server for a profile.
            profileString name ++ "(NotAsked state!)"

        ViewingOther (Loading name) ->
            "Loading " ++ profileString name ++ "…"

        ViewingOther (Failed name) ->
            "Failed loading " ++ profileString name ++ "!"
