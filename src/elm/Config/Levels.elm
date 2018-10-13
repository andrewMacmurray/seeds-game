module Config.Levels exposing
    ( allLevels
    , getLevelConfig
    , getLevelData
    , getLevelNumber
    , lifeRecoveryInterval
    , maxLives
    , shouldIncrement
    )

import Config.World.One as One
import Config.World.Three as Three
import Config.World.Two as Two
import Data.Board.Types exposing (..)
import Data.Level.Progress as Progress
import Data.Level.Settings exposing (..)
import Data.Level.Types exposing (..)
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial


getLevelNumber : Progress -> Int
getLevelNumber =
    Progress.levelNumber allLevels


getLevelData : Progress -> LevelData Tutorial.Config
getLevelData =
    Progress.levelData allLevels >> Maybe.withDefault defaultLevel


getLevelConfig : Progress -> CurrentLevelConfig Tutorial.Config
getLevelConfig =
    Progress.levelConfig allLevels >> Maybe.withDefault ( defaultWorld, defaultLevel )


shouldIncrement : Maybe Progress -> Progress -> Bool
shouldIncrement =
    Progress.shouldIncrement allLevels


allLevels : AllLevels Tutorial.Config
allLevels =
    Dict.fromList
        [ ( 1, One.world )
        , ( 2, Two.world )
        , ( 3, Three.world )
        ]


defaultWorld : WorldData Tutorial.Config
defaultWorld =
    One.world


defaultLevel : LevelData Tutorial.Config
defaultLevel =
    { walls = []
    , boardDimensions = { x = 8, y = 8 }
    , tutorial = Nothing
    , moves = 10
    , tileSettings =
        [ rain
            (Probability 25)
            (TargetScore 50)
        , seed
            Sunflower
            (Probability 25)
            (TargetScore 100)
        , sun
            (Probability 25)
            (TargetScore 50)
        , seedPod
            (Probability 25)
        ]
    }


maxLives : number
maxLives =
    5


lifeRecoveryInterval : Float
lifeRecoveryInterval =
    5 * (60 * 1000)
