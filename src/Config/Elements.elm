module Config.Elements exposing (copyright, credentialed, credit, externalLink, iconified, iconsCredit, inertLink, labeledRight, link, logo, pill, privacyPolicyLink, spinner)

{-| This module is for reusable visual elements, e.g. loading spinners, etc.
Additionally, this module holds general-purpose functions that perform common
transformations on elements, e.g. labeling.
-}

import Config.Assets as Assets
import Config.Strings as Strings
import Config.Styles as Styles
import DeviceProfile exposing (DeviceProfile, responsive)
import Element exposing (Attribute, Element, alignLeft, alignRight, centerX, el, html, image, row, spacing, text)
import Html exposing (div)
import Html.Attributes exposing (class)
import Icon exposing (Icon)
import Route exposing (Route)
import Session exposing (Session)
import Url.Builder as Builder
import Username
import Viewer exposing (Viewer)



-- SPECIFIC ELEMENTS


logo : DeviceProfile -> Element msg
logo deviceProfile =
    let
        logotype =
            responsive deviceProfile
                { compact = Strings.appNameCompact
                , full = Strings.appName
                }
    in
    link []
        { route = Route.Home
        , label =
            row Styles.logo
                [ image []
                    { src = Assets.logo
                    , description = "The " ++ Strings.appName ++ " logo"
                    }
                , text logotype
                ]
        }


spinner : List (Attribute msg) -> Element msg
spinner attrs =
    let
        emptyDiv =
            div [] []
    in
    el attrs <|
        html <|
            div [ class "spinner" ] (List.repeat 4 emptyDiv)


credit : Element msg
credit =
    link [ alignLeft ]
        { route = Route.Profile Username.appAuthor
        , label = text "Made with ♥︎ by Zimmy"
        }


iconsCredit : Element msg
iconsCredit =
    row [ centerX ]
        [ text "Icons by "
        , externalLink []
            { href = Route.icons8
            , label = Icon.view (Icon.icons8 Icon.Small)
            }
        ]


privacyPolicyLink : Element msg
privacyPolicyLink =
    link [ centerX ]
        { route = Route.PrivacyPolicy
        , label = text "Privacy Policy"
        }


copyright : Element msg
copyright =
    externalLink [ alignRight ]
        { href = Route.companyWebsite
        , label = text Strings.copyright
        }



-- ELM-UI API WRAPPER


link : List (Attribute msg) -> { route : Route, label : Element msg } -> Element msg
link attrs { route, label } =
    Element.link attrs { url = Route.toHref route, label = label }


externalLink : List (Attribute msg) -> { href : Route.Href, label : Element msg } -> Element msg
externalLink attrs { href, label } =
    Element.newTabLink attrs { url = Route.toHref (Route.Redirect href), label = label }


inertLink : List (Attribute msg) -> Element msg -> Element msg
inertLink attrs label =
    Element.link attrs { url = Builder.relative [] [], label = label }



-- ELEMENT TRANSFORMATIONS


credentialed : Session -> { loggedIn : Viewer -> Element msg, guest : Element msg } -> Element msg
credentialed session { loggedIn, guest } =
    case Session.viewer session of
        Nothing ->
            guest

        Just vwr ->
            loggedIn vwr


iconified : Icon -> String -> Element msg
iconified icon label =
    Icon.view icon |> labeledRight label


labeledRight : String -> Element msg -> Element msg
labeledRight label element =
    element |> right (text label)


pill : Int -> Element msg -> Element msg
pill count element =
    let
        pillNode =
            el Styles.pill <|
                text (String.fromInt count)
    in
    if count > 0 then
        element |> right pillNode

    else
        element



-- HELPERS


right : Element msg -> Element msg -> Element msg
right r l =
    spaced [ l, r ]


spaced : List (Element msg) -> Element msg
spaced children =
    row [ Styles.smallSpacing ] children
