module Worlds.Two exposing (world)

import Css.Color as Color
import Data.Board.Types exposing (Coord, SeedType(..))
import Data.Board.Wall exposing (..)
import Data.Level.Setting exposing (..)
import Data.Levels as Levels


world : Levels.World
world =
    Levels.world
        { seedType = Chrysanthemum
        , backdropColor = Color.gold
        , textColor = Color.white
        , textCompleteColor = Color.yellow
        , textBackgroundColor = Color.softRed
        }
        levels


levels : List Levels.Level
levels =
    [ Levels.level
        { walls = yellowWalls borders
        , boardDimensions = { x = 8, y = 8 }
        , moves = 10
        , tiles =
            [ seed
                Chrysanthemum
                (Probability 50)
                (TargetScore 50)
            , sun
                (Probability 50)
                (TargetScore 30)
            , seedPod
                (Probability 30)
            ]
        }
    , Levels.level
        { walls = yellowWalls corners
        , boardDimensions = { x = 8, y = 8 }
        , moves = 10
        , tiles =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 30)
            , rain
                (Probability 25)
                (TargetScore 20)
            , seed
                Chrysanthemum
                (Probability 25)
                (TargetScore 30)
            , seedPod
                (Probability 25)
            ]
        }
    , Levels.level
        { walls = yellowWalls innerBorders
        , boardDimensions = { x = 8, y = 8 }
        , moves = 10
        , tiles =
            [ rain
                (Probability 20)
                (TargetScore 20)
            , seed
                Chrysanthemum
                (Probability 20)
                (TargetScore 50)
            , sun
                (Probability 20)
                (TargetScore 20)
            , seedPod
                (Probability 40)
            ]
        }
    , Levels.level
        { walls = yellowWalls fourthLevelWalls
        , boardDimensions = { x = 7, y = 8 }
        , moves = 10
        , tiles =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 50)
            , seed
                Chrysanthemum
                (Probability 25)
                (TargetScore 50)
            , seedPod
                (Probability 40)
            ]
        }
    , Levels.level
        { walls = yellowWalls centerColumns
        , boardDimensions = { x = 8, y = 8 }
        , moves = 10
        , tiles =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 20)
            , sun
                (Probability 30)
                (TargetScore 20)
            , rain
                (Probability 30)
                (TargetScore 20)
            , seed
                Chrysanthemum
                (Probability 25)
                (TargetScore 20)
            ]
        }
    ]


fourthLevelWalls : List Coord
fourthLevelWalls =
    toCoords
        [ [ w, w, s, s, s, w, w ]
        , [ w, s, s, s, s, s, w ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ w, s, s, s, s, s, w ]
        , [ w, w, s, s, s, w, w ]
        ]
