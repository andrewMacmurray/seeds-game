module Utils.Time.Clock exposing
    ( Clock
    , fromMillis
    , minutes
    , seconds
    )

import Utils.Time.Interval as Interval



-- Clock


type Clock
    = Clock Int



-- Construct


fromMillis : Int -> Clock
fromMillis n =
    if n < 0 then
        Clock 0

    else
        Clock n



-- Query


minutes : Clock -> Int
minutes (Clock millis) =
    modBy 60 <| millis // Interval.minute


seconds : Clock -> Int
seconds (Clock millis) =
    modBy 60 <| millis // Interval.second
