module Icon exposing (Icon, Size, binoculars, discord, donate, downArrow, envelope, error, espresso, github, help, icons8, paperPlane, search, size, starBox, success, upArrow, view, wrench)

import Config.Links as Links exposing (Href)
import Element exposing (Element)


type Icon
    = Icon Glyph Size


type Glyph
    = Binoculars
    | Search
    | StarBox
    | PaperPlane
    | Envelope
    | Wrench
    | Espresso
    | Donate
      -- Abstract
    | Success
    | Error
    | Help
    | DownArrow
    | UpArrow
      -- Logos
    | Github
    | Discord
    | Icons8



-- SIZES


type Size
    = Small
    | Medium
    | Large


size : { large : Size, medium : Size, small : Size }
size =
    { small =
        Small
    , medium =
        Medium
    , large =
        Large
    }



-- ICONS (CREATION)


binoculars : Size -> Icon
binoculars =
    Icon Binoculars


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


success : Size -> Icon
success =
    Icon Success


error : Size -> Icon
error =
    Icon Error


help : Size -> Icon
help =
    Icon Help


upArrow : Size -> Icon
upArrow =
    Icon UpArrow


downArrow : Size -> Icon
downArrow =
    Icon DownArrow


github : Size -> Icon
github =
    Icon Github


discord : Size -> Icon
discord =
    Icon Discord


icons8 : Size -> Icon
icons8 =
    Icon Icons8



-- TRANSFORM


view : Icon -> Element msg
view icon =
    Element.image [] { src = source icon, description = "" }



-- HELPERS


source : Icon -> Href
source icon =
    Links.images.icon (filename icon)


filename : Icon -> String
filename (Icon glyph sz) =
    String.join "-" [ "icons8", identifier glyph, String.fromInt (sizeToInt sz) ]
        ++ ".png"


identifier : Glyph -> String
identifier glyph =
    case glyph of
        Binoculars ->
            "binoculars"

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

        Success ->
            "ok"

        Error ->
            "cancel"

        Help ->
            "help"

        DownArrow ->
            "drop-down"

        UpArrow ->
            "up-squared"

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
