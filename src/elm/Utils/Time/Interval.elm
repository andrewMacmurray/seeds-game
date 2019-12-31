module Utils.Time.Interval exposing
    ( Interval
    , minute
    , second
    )


type alias Interval =
    Int


minute : Interval
minute =
    second * 60


second : Interval
second =
    1000
