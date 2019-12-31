module Utils.Time exposing
    ( addMinutesToPosix
    , addSecondsToPosix
    , differenceInMillis
    , millisFromMinutesAndSeconds
    )

import Time
import Utils.Time.Interval as Interval


addSecondsToPosix : Int -> Time.Posix -> Time.Posix
addSecondsToPosix n time =
    Time.millisToPosix (secondsInMillis n + Time.posixToMillis time)


addMinutesToPosix : Int -> Time.Posix -> Time.Posix
addMinutesToPosix n time =
    Time.millisToPosix (minutesInMillis n + Time.posixToMillis time)


differenceInMillis : Time.Posix -> Time.Posix -> Int
differenceInMillis t1 t2 =
    abs (Time.posixToMillis t1 - Time.posixToMillis t2)


millisFromMinutesAndSeconds : Int -> Int -> Int
millisFromMinutesAndSeconds minutes seconds =
    minutesInMillis minutes + secondsInMillis seconds



-- Helpers


minutesInMillis : Int -> Int
minutesInMillis m =
    m * Interval.minute


secondsInMillis : Int -> Int
secondsInMillis s =
    s * Interval.second
