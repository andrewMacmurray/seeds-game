module Worlds.Three exposing (world)

import Css.Color as Color
import Data.Board.Types exposing (Coord, SeedType(..))
import Data.Board.Wall exposing (..)
import Data.Level.Setting.Tile exposing (..)
import Data.Levels as Levels


world : Levels.World
world =
    Levels.world
        { seedType = Cornflower
        , backdropColor = "#1f4a77"
        , textColor = Color.white
        , textCompleteColor = Color.white
        , textBackgroundColor = "rgb(0, 182, 255)"
        }
        levels


levels : List Levels.Level
levels =
    [ Levels.level
        { walls = walls firstLevelWalls
        , startTiles = []
        , boardDimensions = { x = 6, y = 8 }
        , moves = 20
        , tileSettings =
            [ rain
                (Probability 20)
                (TargetScore 50)
            , seed
                Cornflower
                (Probability 20)
                (TargetScore 100)
            , seedPod
                (Probability 40)
            ]
        }
    , Levels.level
        { walls = walls corners
        , moves = 10
        , startTiles = []
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 30)
            , seed
                Cornflower
                (Probability 25)
                (TargetScore 30)
            , rain
                (Probability 25)
                (TargetScore 40)
            , seedPod
                (Probability 25)
            ]
        }
    , Levels.level
        { walls = []
        , moves = 15
        , boardDimensions = { x = 8, y = 8 }
        , startTiles = []
        , tileSettings =
            [ seed
                Chrysanthemum
                (Probability 25)
                (TargetScore 30)
            , seed
                Cornflower
                (Probability 25)
                (TargetScore 30)
            , seed
                Sunflower
                (Probability 25)
                (TargetScore 30)
            , rain
                (Probability 25)
                (TargetScore 30)
            , seedPod
                (Probability 25)
            ]
        }
    ]


firstLevelWalls : List Coord
firstLevelWalls =
    toCoords
        [ [ s, s, s, s, s, s ]
        , [ w, w, w, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, w, w, w ]
        , [ s, s, s, s, s, s ]
        , [ w, w, w, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        ]
