module Device exposing (Profile(..), ResizeHandler, Size, decoder, encode, profile, resizeHandler, responsive)

import Json.Decode as Decode exposing (Decoder, fail, succeed)
import Json.Encode as Encode exposing (Value)


type alias Size =
    ( Int, Int )


type Profile
    = Compact
    | Full


type alias ResizeHandler msg =
    Int -> Int -> msg



-- Device Profiling


resizeHandler : Profile -> { resized : Profile -> msg, noOp : msg } -> ResizeHandler msg
resizeHandler currentProfile { resized, noOp } w h =
    let
        newProfile =
            profile ( w, h )
    in
    if newProfile /= currentProfile then
        resized newProfile

    else
        noOp


profile : Size -> Profile
profile ( w, _ ) =
    if w >= 1180 then
        Full

    else
        Compact


responsive : Profile -> { compact : a, full : a } -> a
responsive prof { compact, full } =
    case prof of
        Compact ->
            compact

        Full ->
            full



-- Serialization


decoder : Decoder Size
decoder =
    let
        isPositiveNonzero =
            (<) 0
    in
    Decode.list Decode.int
        |> Decode.andThen validate


validate : List Int -> Decoder Size
validate dims =
    case dims of
        [ w, h ] ->
            if dims |> List.all ((<) 0) then
                succeed ( w, h )

            else
                fail "Device size with one or more invalid dimensions"

        _ ->
            fail "Device size formatted incorrectly."


encode : Size -> Value
encode ( w, h ) =
    Encode.list Encode.int [ w, h ]
