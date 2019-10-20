module Worlds.One exposing (default, world)

import Css.Color as Color
import Data.Board.Types exposing (Coord, SeedType(..))
import Data.Board.Wall as Wall exposing (s, w)
import Data.Level.Setting.Start as Start
import Data.Level.Setting.Tile exposing (..)
import Data.Levels as Levels


world : Levels.World
world =
    Levels.world
        { seedType = Sunflower
        , backdropColor = Color.yellow
        , textColor = Color.darkYellow
        , textCompleteColor = Color.yellow
        , textBackgroundColor = Color.lightBrown
        }
        levels


levels : List Levels.Level
levels =
    [ Levels.withTutorial Levels.Seed
        { walls = Wall.walls l1Walls
        , startTiles = []
        , boardDimensions = { x = 5, y = 5 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 100)
                (TargetScore 60)
            ]
        }
    , Levels.withTutorial Levels.Rain
        { walls = Wall.walls l2Walls
        , startTiles = l2StartTiles
        , boardDimensions = { x = 6, y = 6 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 50)
                (TargetScore 35)
            , rain
                (Probability 50)
                (TargetScore 35)
            ]
        }
    , Levels.level
        { walls = Wall.walls []
        , startTiles = l3StartTiles
        , boardDimensions = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 20)
                (TargetScore 50)
            , rain
                (Probability 20)
                (TargetScore 50)
            ]
        }
    , Levels.withTutorial Levels.Sun
        { walls = Wall.walls l4Walls
        , startTiles = l4StartTiles
        , boardDimensions = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ rain
                (Probability 33)
                (TargetScore 15)
            , seed
                Sunflower
                (Probability 33)
                (TargetScore 10)
            , sun
                (Probability 33)
                (TargetScore 15)
            ]
        }
    , Levels.level
        { walls = Wall.walls l5Walls
        , startTiles = l5StartTiles
        , moves = 15
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ seed
                Sunflower
                (Probability 50)
                (TargetScore 75)
            , sun
                (Probability 50)
                (TargetScore 75)
            , rain
                (Probability 50)
                (TargetScore 75)
            , burst
                (Probability 10)
            ]
        }
    , Levels.level
        { walls = Wall.walls l6Walls
        , moves = 20
        , startTiles = l6StartTiles
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ seed
                Sunflower
                (Probability 33)
                (TargetScore 50)
            , sun
                (Probability 33)
                (TargetScore 50)
            , rain
                (Probability 33)
                (TargetScore 50)
            , burst
                (Probability 2)
            ]
        }
    , Levels.level
        { walls = Wall.walls l7Walls
        , moves = 8
        , startTiles = l7StartTiles
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ seed
                Sunflower
                (Probability 33)
                (TargetScore 50)
            , sun
                (Probability 33)
                (TargetScore 50)
            , rain
                (Probability 33)
                (TargetScore 50)
            , burst
                (Probability 5)
            ]
        }
    , Levels.level
        { walls = Wall.invisible l8Invisibles ++ Wall.walls l8Walls
        , moves = 10
        , startTiles = l8StartTiles
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ rain
                (Probability 20)
                (TargetScore 30)
            , seed
                Sunflower
                (Probability 31)
                (TargetScore 50)
            , sun
                (Probability 20)
                (TargetScore 30)
            , burst
                (Probability 5)
            ]
        }
    , Levels.level
        { walls = []
        , moves = 5
        , startTiles = []
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ rain
                (Probability 31)
                (TargetScore 30)
            , seed
                Sunflower
                (Probability 31)
                (TargetScore 50)
            , sun
                (Probability 31)
                (TargetScore 30)
            , burst
                (Probability 5)
            ]
        }
    ]


default : Levels.Level
default =
    Levels.level
        { walls = []
        , moves = 10
        , boardDimensions = { x = 8, y = 8 }
        , startTiles = []
        , tileSettings =
            [ rain
                (Probability 25)
                (TargetScore 30)
            , seed
                Sunflower
                (Probability 25)
                (TargetScore 50)
            , sun
                (Probability 25)
                (TargetScore 30)
            , seedPod
                (Probability 25)
            ]
        }


l1Walls : List Coord
l1Walls =
    Wall.toCoords
        [ [ s, s, s, s, s ]
        , [ s, s, s, s, s ]
        , [ s, w, s, w, s ]
        , [ s, s, s, s, s ]
        , [ s, s, s, s, s ]
        ]


l2Walls : List Coord
l2Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        ]


l2StartTiles : List Start.Tile
l2StartTiles =
    List.concat
        [ Start.square (Start.rain 1 1) { size = 6 }
        , Start.square (Start.seed Sunflower 2 2) { size = 4 }
        ]


l3StartTiles : List Start.Tile
l3StartTiles =
    List.concat
        [ Start.square (Start.rain 6 1) { size = 2 }
        , Start.corner (Start.sunflower 5 3) { size = 3, facing = Start.TopRight }
        , Start.corner (Start.rain 4 4) { size = 4, facing = Start.TopRight }
        , Start.corner (Start.sunflower 3 5) { size = 5, facing = Start.TopRight }
        , Start.corner (Start.rain 2 6) { size = 6, facing = Start.TopRight }
        , Start.corner (Start.sunflower 1 7) { size = 7, facing = Start.TopRight }
        ]


l4Walls : List Coord
l4Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        ]


l4StartTiles : List Start.Tile
l4StartTiles =
    List.concat
        [ Start.corner (Start.rain 1 1) { size = 4, facing = Start.BottomRight }
        , Start.corner (Start.sun 7 7) { size = 4, facing = Start.TopLeft }
        ]


l5Walls : List Coord
l5Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l5StartTiles : List Start.Tile
l5StartTiles =
    List.concat
        [ Start.square (Start.sun 1 1) { size = 8 }
        , Start.square (Start.sunflower 2 2) { size = 6 }
        , Start.rectangle (Start.sun 4 1) { x = 2, y = 8 }
        , Start.square (Start.burst 4 4) { size = 2 }
        ]


l6Walls : List Coord
l6Walls =
    Wall.toCoords
        [ [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l6StartTiles : List Start.Tile
l6StartTiles =
    List.concat
        [ Start.line (Start.rain 3 1) { length = 8, direction = Start.Vertical }
        , Start.line (Start.sun 6 1) { length = 8, direction = Start.Vertical }
        , [ Start.burst 4 5
          , Start.burst 5 4
          ]
        ]


l7Walls : List Coord
l7Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l7StartTiles : List Start.Tile
l7StartTiles =
    List.concat
        [ Start.square (Start.sunflower 1 1) { size = 8 }
        , Start.square (Start.sun 2 2) { size = 6 }
        , Start.square (Start.rain 3 3) { size = 4 }
        ]


l8Walls : List Coord
l8Walls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, w, s, s, w, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, w, s, s, w, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l8Invisibles : List Coord
l8Invisibles =
    Wall.toCoords
        [ [ w, w, s, s, s, s, w, w ]
        , [ w, w, s, s, s, s, w, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, w, s, s, s, s, w, w ]
        , [ w, w, s, s, s, s, w, w ]
        ]


l8StartTiles : List Start.Tile
l8StartTiles =
    List.concat
        [ Start.square (Start.sunflower 4 4) { size = 2 }
        , Start.square (Start.rain 2 4) { size = 2 }
        , Start.square (Start.rain 6 4) { size = 2 }
        , Start.square (Start.sun 4 6) { size = 2 }
        , Start.square (Start.sun 4 2) { size = 2 }
        , [ Start.burst 1 4, Start.burst 8 5 ]
        ]
