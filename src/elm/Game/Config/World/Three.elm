module Game.Config.World.Three exposing (world)

import Element.Palette as Palette
import Game.Board.Coord exposing (Coord)
import Game.Board.Wall as Wall exposing (..)
import Game.Config.Level as Level
import Game.Level.Setting.Constant as Constant
import Game.Level.Setting.Tile exposing (..)
import Seed exposing (Seed(..))



-- World Three


world : Level.World
world =
    Level.world
        { seed = Cornflower
        , backdropColor = Palette.blue2
        , textColor = Palette.white
        , textCompleteColor = Palette.white
        , textBackgroundColor = Palette.blue5
        }
        levels


levels : List Level.Level
levels =
    [ Level.level
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
    , Level.level
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
    , Level.level
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


l2StartingTiles : List Constant.Tile
l2StartingTiles =
    Constant.square (Constant.burst 4 4) { size = 2 }
