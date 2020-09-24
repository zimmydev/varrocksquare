module Settings exposing (DateFormat(..), Settings, TimeFormat(..), Timestamps(..), default)


type alias Settings =
    { alerts : Bool
    , timestamps : Timestamps
    }



-- Timestamps


type Timestamps
    = Relative -- e.g. "17 minutes ago", "5 hours ago", "12 days ago", "2 years ago", etc.
    | Absolute DateFormat TimeFormat -- e.g. "Feb 17, '21 at 5:30 PM"


type DateFormat
    = ShortDate -- e.g. "02/17/21"
    | MediumDate -- e.g. "Feb 17, '21"
    | LongDate -- e.g. "February 17, 2021"


type TimeFormat
    = TwelveHour -- e.g. "5:30 PM"
    | TwentyFourHour -- e.g. "17:30"



-- Defaults


default =
    { alerts = True
    , timestamps = Relative
    }
