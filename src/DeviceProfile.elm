module DeviceProfile exposing (DeviceProfile(..), DeviceSize, profile, responsive)

-- TYPES


type alias DeviceSize =
    { width : Int, height : Int }


type DeviceProfile
    = Compact
    | Full



-- CREATION


profile : DeviceSize -> DeviceProfile
profile { width } =
    if width >= 1180 then
        Full

    else
        Compact



-- TRANSFORMATION


responsive : DeviceProfile -> { compact : a, full : a } -> a
responsive deviceProfile { compact, full } =
    case deviceProfile of
        Compact ->
            compact

        Full ->
            full
