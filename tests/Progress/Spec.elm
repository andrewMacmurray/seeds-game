module Progress.Spec exposing (spec)

import BDD exposing (..)
import Data.Levels as Levels
import Data.Progress as Progress
import Expect exposing (..)
import Test exposing (..)


spec : Test
spec =
    describe "Progress"
        [ currentLevelComplete
        ]


currentLevelComplete : Test
currentLevelComplete =
    describe "currentLevelComplete"
        [ it "returns true if current level is complete" <|
            let
                complete =
                    progress 1 5
                        |> Progress.setCurrentLevel (level 1 3)
                        |> Progress.currentLevelComplete
            in
            expect complete toEqual True
        , it "returns false if current level is same as reached" <|
            let
                complete =
                    progress 1 5
                        |> Progress.setCurrentLevel (level 1 5)
                        |> Progress.currentLevelComplete
            in
            expect complete toEqual False
        , it "returns false if no current level" <|
            let
                complete =
                    progress 1 5 |> Progress.currentLevelComplete
            in
            expect complete toEqual False
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
