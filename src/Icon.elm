module Icon exposing (Icon, Size, binoculars, discord, donate, envelope, error, espresso, github, help, icons8, large, linkEnvelope, medium, paperPlane, search, small, starBox, success, view, toolbox)

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
    | LinkEnvelope
    | Toolbox
    | Espresso
    | Donate
      -- Abstract
    | Success
    | Error
    | Help
      -- Logos
    | Github
    | Discord
    | Icons8



-- SIZES


type Size
    = Small
    | Medium
    | Large


small : Size
small =
    Small


medium : Size
medium =
    Medium


large : Size
large =
    Large



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


linkEnvelope : Size -> Icon
linkEnvelope =
    Icon LinkEnvelope


toolbox : Size -> Icon
toolbox =
    Icon Toolbox


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
    Links.icon (filename icon)


filename : Icon -> String
filename (Icon glyph size) =
    String.join "-" [ "icons8", identifier glyph, String.fromInt (intSize size) ]
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

        LinkEnvelope ->
            "message-link"

        Toolbox ->
            "toolbox"

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

        Github ->
            "github"

        Discord ->
            "discord"

        Icons8 ->
            "icons8"


intSize : Size -> Int
intSize size =
    case size of
        Small ->
            16

        Medium ->
            24

        Large ->
            32
