module Device exposing (Profile, ResizeHandler, Size, decoder, profile, resizeHandler, responsive)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type alias Size =
    { width : Int, height : Int }


type Profile
    = Compact
    | Full


type alias ResizeHandler msg =
    Int -> Int -> msg



-- Device Profiling


resizeHandler : Profile -> { resized : Profile -> msg, noOp : msg } -> ResizeHandler msg
resizeHandler currentProfile { resized, noOp } width height =
    let
        newProfile =
            profile (Size width height)
    in
    if newProfile /= currentProfile then
        resized newProfile

    else
        noOp


profile : Size -> Profile
profile { width } =
    if width >= 1180 then
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
    Decode.succeed Size
        |> required "width" Decode.int
        |> required "height" Decode.int
