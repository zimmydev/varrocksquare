module Icon exposing (Icon, Size(..), arrow, binoculars, discord, donate, envelope, error, espresso, github, help, icons8, notifications, paperPlane, pencil, radioFocused, radioOff, radioOn, search, settings, starBox, success, view, wrench)

{-| TODO: Merge into `Config.Assets`!
-}

import Config.Assets as Assets
import Element exposing (Element)


type Icon
    = Icon Glyph Size


type Glyph
    = Binoculars
    | Pencil
    | Search
    | StarBox
    | PaperPlane
    | Envelope
    | Wrench
    | Espresso
    | Donate
    | Settings
      --| Logout
      -- Abstract
    | Success
    | Error
    | Help
    | DownArrow
    | UpArrow
    | RadioOn
    | RadioOff
    | RadioFocused
      -- Setting toggles
    | NotificationsActive
    | NotificationsInactive
      -- Logos
    | Github
    | Discord
    | Icons8


type alias Href =
    String



-- SIZES


type Size
    = Small
    | Medium
    | Large



-- ICONS (CREATION)


binoculars : Size -> Icon
binoculars =
    Icon Binoculars


pencil : Size -> Icon
pencil =
    Icon Pencil


search : Size -> Icon
search =
    Icon Search


starBox : Size -> Icon
starBox =
    Icon StarBox


paperPlane : Size -> Icon
paperPlane =
    Icon PaperPlane


envelope : Size -> Icon
envelope =
    Icon Envelope


wrench : Size -> Icon
wrench =
    Icon Wrench


espresso : Size -> Icon
espresso =
    Icon Espresso


donate : Size -> Icon
donate =
    Icon Donate


settings : Size -> Icon
settings =
    Icon Settings



{-
   logout : Size -> Icon
   logout =
       Icon Logout
-}


success : Size -> Icon
success =
    Icon Success


error : Size -> Icon
error =
    Icon Error


help : Size -> Icon
help =
    Icon Help


arrow : Bool -> Size -> Icon
arrow isOpen =
    if isOpen then
        Icon UpArrow

    else
        Icon DownArrow


radioOn : Size -> Icon
radioOn =
    Icon RadioOn


radioOff : Size -> Icon
radioOff =
    Icon RadioOff


radioFocused : Size -> Icon
radioFocused =
    Icon RadioFocused


github : Size -> Icon
github =
    Icon Github


discord : Size -> Icon
discord =
    Icon Discord


icons8 : Size -> Icon
icons8 =
    Icon Icons8


notifications : Bool -> Size -> Icon
notifications toggle =
    if toggle then
        Icon NotificationsActive

    else
        Icon NotificationsInactive



-- TRANSFORM


view : Icon -> Element msg
view icon =
    Element.image [] { src = source icon, description = "" }



-- HELPERS


source : Icon -> Href
source icon =
    Assets.icon (filename icon)


filename : Icon -> String
filename (Icon glyph sz) =
    String.join "-" [ "icons8", identifier glyph, String.fromInt (sizeToInt sz) ]
        ++ ".png"


identifier : Glyph -> String
identifier glyph =
    case glyph of
        Binoculars ->
            "binoculars"

        Pencil ->
            "pencil"

        Search ->
            "search"

        StarBox ->
            "rating"

        PaperPlane ->
            "mail-send"

        Envelope ->
            "mail"

        Wrench ->
            "wrench"

        Espresso ->
            "espresso-cup"

        Donate ->
            "donate"

        Settings ->
            "settings"

        Success ->
            "ok"

        Error ->
            "cancel"

        Help ->
            "help"

        DownArrow ->
            "menu-down"

        UpArrow ->
            "menu-up"

        RadioOn ->
            "radio-on"

        RadioOff ->
            "radio-off"

        RadioFocused ->
            "radio-focused"

        NotificationsActive ->
            "notifications-active"

        NotificationsInactive ->
            "notifications-inactive"

        Github ->
            "github"

        Discord ->
            "discord"

        Icons8 ->
            "icons8"


sizeToInt : Size -> Int
sizeToInt sz =
    case sz of
        Small ->
            16

        Medium ->
            24

        Large ->
            32
