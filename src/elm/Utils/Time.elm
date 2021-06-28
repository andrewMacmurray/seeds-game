module Utils.Time exposing
    ( minutes
    , oneSecond
    )


minutes : Int -> Int
minutes n =
    n * oneMinute


oneMinute : Int
oneMinute =
    oneSecond * 60


oneSecond : Int
oneSecond =
    1000
