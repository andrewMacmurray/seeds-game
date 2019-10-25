module Worlds.Three exposing (world)

import Board.Coord exposing (Coord)
import Board.Tile exposing (SeedType(..))
import Board.Wall as Wall exposing (..)
import Css.Color as Color
import Level.Setting.Start as Start
import Level.Setting.Tile exposing (..)
import Levels


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
        , boardSize = { x = 6, y = 8 }
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
        , boardSize = { x = 8, y = 8 }
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
        , boardSize = { x = 8, y = 8 }
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
