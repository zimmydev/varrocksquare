module Device exposing (Profile(..), ResizeHandler, Size, decoder, encode, profile, resizeHandler, responsive)

import Json.Decode as Decode exposing (Decoder)
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
        |> Decode.andThen
            (\ints ->
                case ints of
                    [ w, h ] ->
                        if ints |> List.all isPositiveNonzero then
                            Decode.succeed ( w, h )

                        else
                            Decode.fail "Attempted to decode device size with one or more zero or negative dimensions"

                    _ ->
                        Decode.fail "Device size was in the incorrect format; use an list of 2 elements corresponding to width and height, respectively"
            )


encode : Size -> Value
encode ( w, h ) =
    Encode.list Encode.int [ w, h ]
