module Scene.Level.Challenge exposing
    ( Challenge(..)
    , TimeRemaining
    , adjustStartTimeBy
    , decrementTime
    , failed
    , moveLimit
    , timeLimit
    )

import Time
import Utils.Time as Time



-- Challenge


type Challenge
    = MoveLimit Int
    | TimeLimit TimeRemaining


type TimeRemaining
    = TimeRemaining
        { currentTime : Time.Posix
        , remainingMillis : Int
        }



-- Construct


moveLimit : Int -> Challenge
moveLimit =
    MoveLimit


timeLimit : Int -> Int -> Time.Posix -> Challenge
timeLimit minutes seconds startTime =
    Time.millisFromMinutesAndSeconds minutes seconds
        |> initTimeRemaining startTime
        |> TimeLimit


initTimeRemaining : Time.Posix -> Int -> TimeRemaining
initTimeRemaining startTime millis =
    TimeRemaining
        { currentTime = startTime
        , remainingMillis = millis
        }



-- Query


failed : Challenge -> Bool
failed challenge =
    case challenge of
        MoveLimit _ ->
            False

        TimeLimit (TimeRemaining { remainingMillis }) ->
            remainingMillis <= 0



-- Update


adjustStartTimeBy : Int -> Challenge -> Challenge
adjustStartTimeBy seconds =
    updateTimeLimit (addSecondsToStartTime seconds)


decrementTime : Time.Posix -> Challenge -> Challenge
decrementTime time =
    updateTimeLimit (decrementTimeRemaining time)


addSecondsToStartTime : Int -> TimeRemaining -> TimeRemaining
addSecondsToStartTime seconds (TimeRemaining r) =
    TimeRemaining { r | currentTime = Time.addSecondsToPosix seconds r.currentTime }


decrementTimeRemaining : Time.Posix -> TimeRemaining -> TimeRemaining
decrementTimeRemaining newTime (TimeRemaining r) =
    let
        newRemainingMillis =
            r.remainingMillis - Time.differenceInMillis newTime r.currentTime
    in
    TimeRemaining
        { remainingMillis = newRemainingMillis
        , currentTime = newTime
        }



-- Helpers


updateTimeLimit : (TimeRemaining -> TimeRemaining) -> Challenge -> Challenge
updateTimeLimit f challenge =
    case challenge of
        TimeLimit timeRemaining ->
            TimeLimit (f timeRemaining)

        x ->
            x
