module Scene.Level.Challenge exposing
    ( Challenge(..)
    , TimeRemaining
    , moveLimit
    , timeLimit
    )

-- Challenge


type Challenge
    = MoveLimit Int
    | TimeLimit TimeRemaining


type TimeRemaining
    = TimeRemaining Int



-- Construct


moveLimit : Int -> Challenge
moveLimit =
    MoveLimit


timeLimit : Int -> Int -> Challenge
timeLimit minutes seconds =
    timeInMillis minutes seconds
        |> TimeRemaining
        |> TimeLimit



-- Helpers


timeInMillis : Int -> Int -> Int
timeInMillis minutes seconds =
    minutesInMillis minutes + secondsInMillis seconds


minutesInMillis : Int -> Int
minutesInMillis m =
    m * 60 * oneSecond


secondsInMillis : Int -> Int
secondsInMillis s =
    s * oneSecond


oneSecond : Int
oneSecond =
    1000
