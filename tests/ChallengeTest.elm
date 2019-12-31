module ChallengeTest exposing (timeRemainingSuite)

import Expect
import Fuzz exposing (intRange)
import Random
import Scene.Level.Challenge as Challenge
import Test exposing (Test, describe, fuzz2)
import Time
import Utils.Time as Time


timeRemainingSuite : Test
timeRemainingSuite =
    describe "TimeRemaining Challenge"
        [ fuzz2 (aboveAndIncluding 0) (aboveAndIncluding 1) "Is not failed when started" <|
            \minutes seconds ->
                Challenge.timeLimit minutes seconds startTime
                    |> Challenge.failed
                    |> Expect.equal False
        , fuzz2 (intRange 0 1) (intRange 1 29) "is not failed if time limit has not been reached" <|
            \minutes seconds ->
                Challenge.timeLimit 1 30 startTime
                    |> decrementTimeBy minutes seconds startTime
                    |> Challenge.failed
                    |> Expect.equal False
        , fuzz2 (aboveAndIncluding 1) (aboveAndIncluding 31) "is failed when time limit reached" <|
            \minutes seconds ->
                Challenge.timeLimit 1 30 startTime
                    |> decrementTimeBy minutes seconds startTime
                    |> Challenge.failed
                    |> Expect.equal True
        ]


startTime : Time.Posix
startTime =
    Time.millisToPosix 1000000



-- Helpers


aboveAndIncluding : Int -> Fuzz.Fuzzer Int
aboveAndIncluding n =
    intRange n Random.maxInt


decrementTimeBy : Int -> Int -> Time.Posix -> Challenge.Challenge -> Challenge.Challenge
decrementTimeBy minutes seconds =
    Time.addSecondsToPosix seconds
        >> Time.addMinutesToPosix minutes
        >> Challenge.decrementTime
