module Utils.Time.Clock exposing
    ( Clock
    , init
    , readout
    )

import Utils.Time as Time



-- Clock


type alias Clock =
    { minutes : Int
    , seconds : Int
    }


type alias Millis =
    Int



-- Init


init : Millis -> Clock
init millis =
    { minutes = millis // Time.oneMinute
    , seconds = modBy 60 (millis // Time.oneSecond)
    }



-- View


readout : Clock -> String
readout clock =
    String.fromInt clock.minutes ++ ":" ++ viewSecond clock.seconds


viewSecond : Int -> String
viewSecond n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n
