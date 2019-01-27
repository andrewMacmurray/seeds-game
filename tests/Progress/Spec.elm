module Progress.Spec exposing (spec)

import Data.Levels as Levels
import Data.Progress as Progress
import Expect exposing (..)
import Test exposing (..)


spec : Test
spec =
    describe "Progress"
        [ currentLevelCompleteSpec
        ]


currentLevelCompleteSpec : Test
currentLevelCompleteSpec =
    describe "currentLevelComplete"
        [ test "is True if current level is complete" <|
            \_ ->
                progress 1 5
                    |> Progress.setCurrentLevel (level 1 3)
                    |> Progress.currentLevelComplete
                    |> Expect.equal (Just True)
        , test "is False if current level is same as reached" <|
            \_ ->
                progress 1 5
                    |> Progress.setCurrentLevel (level 1 5)
                    |> Progress.currentLevelComplete
                    |> Expect.equal (Just False)
        , test "is Nothing if no current level" <|
            \_ ->
                progress 1 5
                    |> Progress.currentLevelComplete
                    |> Expect.equal Nothing
        ]


level : Int -> Int -> Levels.Key
level =
    Levels.keyFromRaw_


progress : Int -> Int -> Progress.Progress
progress w l =
    Progress.fromCache <|
        Just
            { worldId = w
            , levelId = l
            }
