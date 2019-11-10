module Config.World.Two exposing (world)

import Board.Coord as Coord exposing (Coord)
import Board.Wall exposing (..)
import Config.Level as Level
import Css.Color as Color
import Level.Setting.Start as Start
import Level.Setting.Tile exposing (..)
import Scene.Level.Tutorial as Tutorial
import Seed exposing (Seed(..))


world : Level.World
world =
    Level.world
        { seed = Chrysanthemum
        , backdropColor = Color.gold
        , textColor = Color.white
        , textCompleteColor = Color.yellow
        , textBackgroundColor = Color.softRed
        }
        levels


levels : List Level.Level
levels =
    [ Level.withTutorial l1Tutorial
        { walls = walls firstLevelWalls
        , startTiles = l1StartTiles
        , boardSize = { x = 8, y = 8 }
        , moves = 5
        , tileSettings =
            [ seed
                Chrysanthemum
                (Probability 5)
                (TargetScore 50)
            , seedPod
                (Probability 80)
            ]
        }
    , Level.level
        { walls = walls corners
        , startTiles = []
        , boardSize = { x = 8, y = 8 }
        , moves = 10
        , tileSettings =
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
            , burst
                (Probability 6)
            ]
        }
    , Level.level
        { walls = walls l3Walls
        , startTiles = l3StartTiles
        , boardSize = { x = 8, y = 8 }
        , moves = 10
        , tileSettings =
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
            , burst
                (Probability 5)
            ]
        }
    , Level.level
        { walls = walls l4Walls
        , startTiles = l4StartTiles
        , boardSize = { x = 7, y = 8 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 35)
            , seed
                Chrysanthemum
                (Probability 25)
                (TargetScore 35)
            , seedPod
                (Probability 60)
            ]
        }
    , Level.level
        { walls = walls l5Walls
        , startTiles = l5StartTiles
        , boardSize = { x = 8, y = 8 }
        , moves = 7
        , tileSettings =
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


firstLevelWalls : List Coord
firstLevelWalls =
    toCoords
        [ [ w, s, s, w, w, s, s, w ]
        , [ w, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, w, w, s, s, w ]
        , [ w, s, s, w, w, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, w ]
        , [ w, s, s, w, w, s, s, w ]
        ]


l1Tutorial : Tutorial.Tutorial
l1Tutorial =
    let
        tileHighlight =
            Tutorial.horizontalTiles { from = Coord.fromXY 3 7, length = 4 }
    in
    Tutorial.tutorial (Tutorial.step "Pods grow into seeds" tileHighlight) []


l1StartTiles : List Start.Tile
l1StartTiles =
    Start.line (Start.seedPod 3 7) { length = 4, direction = Start.Horizontal }


l3Walls : List Coord
l3Walls =
    toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


l3StartTiles : List Start.Tile
l3StartTiles =
    List.concat
        [ Start.square (Start.chrysanthemum 3 3) { size = 4 }
        , Start.corner (Start.sun 1 1) { size = 3, facing = Start.BottomRight }
        , Start.corner (Start.sun 8 1) { size = 3, facing = Start.BottomLeft }
        , Start.corner (Start.rain 1 8) { size = 3, facing = Start.TopRight }
        , Start.corner (Start.rain 8 8) { size = 3, facing = Start.TopLeft }
        , [ Start.burst 3 3
          , Start.burst 6 6
          ]
        , Start.square (Start.seedPod 4 4) { size = 2 }
        , Start.square (Start.seedPod 4 1) { size = 2 }
        , Start.square (Start.seedPod 4 7) { size = 2 }
        ]


l4Walls : List Coord
l4Walls =
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


l4StartTiles : List Start.Tile
l4StartTiles =
    [ Start.burst 4 1
    , Start.burst 4 2
    , Start.burst 4 7
    , Start.burst 4 8
    ]


l5Walls : List Coord
l5Walls =
    toCoords
        [ [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        ]


l5StartTiles : List Start.Tile
l5StartTiles =
    List.concat
        [ Start.line (Start.rain 1 4) { length = 4, direction = Start.Horizontal }
        , Start.line (Start.rain 1 5) { length = 4, direction = Start.Horizontal }
        , Start.line (Start.sun 5 4) { length = 4, direction = Start.Horizontal }
        , Start.line (Start.sun 5 5) { length = 4, direction = Start.Horizontal }
        , Start.square (Start.sun 5 4) { size = 2 }
        , [ Start.burst 3 3
          , Start.burst 6 3
          , Start.burst 3 6
          , Start.burst 6 6
          ]
        ]
