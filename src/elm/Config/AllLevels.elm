module Config.AllLevels exposing (..)

import Config.World.One as One
import Config.World.Two as Two
import Config.World.Three as Three
import Data.Hub.World exposing (..)
import Dict exposing (Dict)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (..)


allLevels : AllLevels
allLevels =
    Dict.fromList
        [ ( 1, One.world )
        , ( 2, Two.world )
        , ( 3, Three.world )
        ]


defaultWorld : WorldData
defaultWorld =
    One.world


defaultLevel : LevelData
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
