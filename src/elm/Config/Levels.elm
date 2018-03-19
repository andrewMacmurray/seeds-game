module Config.Levels exposing (..)

import Config.World.One as One
import Config.World.Three as Three
import Config.World.Two as Two
import Data2.Level.Settings exposing (..)
import Data2.Tile exposing (..)
import Dict exposing (Dict)
import Time exposing (Time, minute)
import Scenes.Tutorial.Types as Tutorial


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


lifeRecoveryInterval : Time
lifeRecoveryInterval =
    5 * minute
