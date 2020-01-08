module Scene.Level.Challenge exposing
    ( Challenge(..)
    , MovesRemaining
    , TimeRemaining
    , adjustStartTimeBy
    , clock
    , decrementTime
    , failed
    , moveLimit
    , percentTimeRemaining
    , timeLimit
    )

import Time
import Utils.Time as Time
import Utils.Time.Clock as Clock exposing (Clock)



-- Challenge


type Challenge
    = MoveLimit MovesRemaining
    | TimeLimit TimeRemaining


type TimeRemaining
    = TimeRemaining
        { currentTime : Time.Posix
        , initialMillis : Int
        , remainingMillis : Int
        }


type alias MovesRemaining =
    Int



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
        , initialMillis = millis
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


clock : TimeRemaining -> Clock
clock (TimeRemaining r) =
    Clock.fromMillis r.remainingMillis


percentTimeRemaining : TimeRemaining -> Int
percentTimeRemaining (TimeRemaining r) =
    let
        percent =
            toFloat r.remainingMillis / toFloat r.initialMillis
    in
    round (percent * 100)



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
        { r
            | remainingMillis = newRemainingMillis
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
