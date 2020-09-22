module Config.Layout exposing (applyIcon, copyright, credit, externalLink, fullscreenOrNone, inertLink, label, link, logo, pill, privacyPolicyLink, spinner)

{-| This module is for reusable visual elements, e.g. loading spinners, etc.
Additionally, this module holds general-purpose functions that perform common
transformations on elements, e.g. labeling, applying an icon, etc.
-}

import Config.Assets as Assets
import Config.Strings as Strings
import Config.Styles as Styles
import Device
import Element exposing (..)
import Html exposing (div)
import Html.Attributes exposing (class)
import Icon exposing (Icon)
import LoggedInUser exposing (LoggedInUser)
import Route exposing (Route)
import Session exposing (Session)
import Url.Builder as Builder
import Username



-- Navbar


logo : Device.Profile -> Element msg
logo devpro =
    let
        logotype =
            Device.responsive devpro
                { compact = Strings.appNameCompact
                , full = Strings.appName
                }
    in
    link []
        { route = Route.Home
        , body =
            row Styles.logo
                [ image []
                    { src = Assets.logo
                    , description = "The " ++ Strings.appName ++ " logo"
                    }
                , text logotype
                ]
        }



-- Footer


credit : Element msg
credit =
    link [ alignLeft ]
        { route = Route.Profile Username.appAuthor
        , body = text "Made with ♥︎ by Zimmy"
        }


privacyPolicyLink : Element msg
privacyPolicyLink =
    link [ centerX ]
        { route = Route.PrivacyPolicy
        , body = text "Privacy Policy"
        }


copyright : Element msg
copyright =
    externalLink [ alignRight ]
        { href = Route.companyWebsite
        , body = text Strings.copyright
        }



-- Page


spinner : List (Attribute msg) -> Element msg
spinner attrs =
    let
        emptyDiv =
            div [] []
    in
    el (attrs ++ Styles.spinner) <|
        html <|
            div [ class "spinner" ] (List.repeat 4 emptyDiv)



-- mdgriffith/elm-ui API Wrappers


link : List (Attribute msg) -> { route : Route, body : Element msg } -> Element msg
link attrs { route, body } =
    Element.link attrs
        { url = Route.toHref route, label = body }


externalLink : List (Attribute msg) -> { href : Route.Href, body : Element msg } -> Element msg
externalLink attrs { href, body } =
    Element.newTabLink attrs
        { url = Route.toHref (Route.Redirect href), label = body }


inertLink : List (Attribute msg) -> Element msg -> Element msg
inertLink attrs body =
    Element.link attrs
        { url = Builder.relative [] [], label = body }



-- Transforming an Element


fullscreenOrNone : Device.Profile -> Element msg -> Element msg
fullscreenOrNone devpro element =
    Device.responsive devpro
        { full = element
        , compact = none
        }


applyIcon : Icon -> String -> Element msg
applyIcon icon lbl =
    Icon.view icon
        |> label lbl


label : String -> Element msg -> Element msg
label lbl element =
    place
        { left = element
        , right = text lbl
        }


pill : Int -> Element msg -> Element msg
pill count element =
    let
        pillNode =
            el Styles.pill <|
                text (String.fromInt count)
    in
    if count > 0 then
        place
            { left = element
            , right = pillNode
            }

    else
        element



-- Helpers


place : { left : Element msg, right : Element msg } -> Element msg
place { left, right } =
    smallSpace [ left, right ]


smallSpace : List (Element msg) -> Element msg
smallSpace children =
    row [ Styles.smallSpacing ] children
