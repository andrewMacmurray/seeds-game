module Worlds.Three exposing (world)

import Css.Color as Color
import Data.Board.Types exposing (Coord, SeedType(..))
import Data.Board.Wall as Wall exposing (..)
import Data.Level.Setting.Start as Start
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
        { walls = walls l1Walls
        , startTiles = []
        , boardDimensions = { x = 6, y = 8 }
        , moves = 20
        , tileSettings =
            [ rain
                (Probability 20)
                (TargetScore 40)
            , seed
                Cornflower
                (Probability 20)
                (TargetScore 80)
            , seedPod
                (Probability 40)
            , burst
                (Probability 5)
            ]
        }
    , Levels.level
        { walls = Wall.walls Wall.corners
        , moves = 10
        , startTiles = l2StartingTiles
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
                (TargetScore 20)
            , seedPod
                (Probability 25)
            ]
        }
    , Levels.level
        { walls = []
        , moves = 10
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
            , burst
                (Probability 10)
            ]
        }
    ]


l1Walls : List Coord
l1Walls =
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


l2StartingTiles : List Start.Tile
l2StartingTiles =
    List.concat
        [ Start.square (Start.burst 4 4) { size = 2 }
        ]
