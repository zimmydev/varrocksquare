module Device exposing (Profile, Size, decoder, profile, responsive)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)



-- TYPES


type alias Size =
    { width : Int, height : Int }


type Profile
    = Compact
    | Full



-- PROFILING


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



-- SIZE SERIALIZATION


decoder : Decoder Size
decoder =
    Decode.succeed Size
        |> required "width" Decode.int
        |> required "height" Decode.int
