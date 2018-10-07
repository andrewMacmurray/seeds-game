module Config.Levels exposing
    ( allLevels
    , getLevelConfig
    , getLevelData
    , lifeRecoveryInterval
    , maxLives
    )

import Config.World.One as One
import Config.World.Three as Three
import Config.World.Two as Two
import Data.Board.Types exposing (..)
import Data.Level.Progress exposing (levelConfig, levelData)
import Data.Level.Settings exposing (..)
import Data.Level.Types exposing (..)
import Dict exposing (Dict)
import Scenes.Tutorial.Types exposing (TutorialConfig)


getLevelData : Progress -> LevelData TutorialConfig
getLevelData =
    levelData allLevels >> Maybe.withDefault defaultLevel


getLevelConfig : Progress -> CurrentLevelConfig TutorialConfig
getLevelConfig =
    levelConfig allLevels >> Maybe.withDefault ( defaultWorld, defaultLevel )


allLevels : AllLevels TutorialConfig
allLevels =
    Dict.fromList
        [ ( 1, One.world )
        , ( 2, Two.world )
        , ( 3, Three.world )
        ]


defaultWorld : WorldData TutorialConfig
defaultWorld =
    One.world


defaultLevel : LevelData TutorialConfig
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
