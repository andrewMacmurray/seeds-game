module Utils.Time.Clock exposing
    ( Clock
    , fromMillis
    , render
    )

import Utils.Time.Interval as Interval



-- Clock


type Clock
    = Clock Int


type alias Output =
    { minutes : String
    , seconds : String
    }



-- Construct


fromMillis : Int -> Clock
fromMillis n =
    if n < 0 then
        Clock 0

    else
        Clock n



-- Query


render : Clock -> Output
render clock =
    { minutes = String.fromInt (minutes clock)
    , seconds = renderSecond (seconds clock)
    }



-- Helpers


minutes : Clock -> Int
minutes (Clock millis) =
    modBy 60 <| millis // Interval.minute


seconds : Clock -> Int
seconds (Clock millis) =
    modBy 60 <| millis // Interval.second


renderSecond : Int -> String
renderSecond n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n
