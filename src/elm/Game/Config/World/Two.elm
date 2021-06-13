module Game.Config.World.Two exposing (world)

import Element
import Element.Palette as Palette
import Game.Board.Coord as Coord exposing (Coord)
import Game.Board.Wall exposing (..)
import Game.Config.Level as Level
import Game.Level.Setting.Start as Start
import Game.Level.Setting.Tile exposing (..)
import Game.Level.Tutorial as Tutorial exposing (Tutorial)
import Seed exposing (Seed(..))



-- World Two


world : Level.World
world =
    Level.world
        { seed = Chrysanthemum
        , backdropColor = Element.rgb255 255 163 0
        , textColor = Palette.white
        , textCompleteColor = Palette.white
        , textBackgroundColor = Element.rgb255 198 53 124
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
    , Level.withTutorial l2Tutorial
        { walls = []
        , startTiles = l2StartTiles
        , boardSize = { x = 8, y = 8 }
        , moves = 8
        , tileSettings =
            [ seed
                Chrysanthemum
                (Probability 5)
                (TargetScore 50)
            , seed
                Sunflower
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
        , moves = 7
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
        { walls = walls diagonal
        , startTiles = l4StartTiles
        , boardSize = { x = 8, y = 8 }
        , moves = 7
        , tileSettings =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 30)
            , sun
                (Probability 25)
                (TargetScore 20)
            , seed
                Chrysanthemum
                (Probability 25)
                (TargetScore 30)
            , seedPod
                (Probability 5)
            , burst
                (Probability 6)
            ]
        }
    , Level.level
        { walls = walls l5Walls
        , startTiles = l5StartTiles
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
        { walls = walls l6Walls
        , startTiles = []
        , boardSize = { x = 7, y = 8 }
        , moves = 7
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
        { walls = walls lWalls
        , startTiles = l7StartTiles
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


l1Tutorial : Tutorial
l1Tutorial =
    let
        tileHighlight =
            Tutorial.horizontalTiles { from = Coord.fromXY 3 7, length = 4 }
    in
    Tutorial.tutorial (Tutorial.step "Connect pods to release seeds" tileHighlight) []


l1StartTiles : List Start.Tile
l1StartTiles =
    Start.line (Start.seedPod 3 7) { length = 4, direction = Start.Horizontal }


l2Tutorial : Tutorial.Tutorial
l2Tutorial =
    let
        tileHighlight =
            Tutorial.horizontalTiles { from = Coord.fromXY 3 4, length = 4 }
    in
    Tutorial.tutorial (Tutorial.step "Pods release the same seed they touch" tileHighlight) []


l2StartTiles : List Start.Tile
l2StartTiles =
    List.concat
        [ Start.square (Start.seedPod 1 1) { size = 8 }
        , [ Start.sunflower 5 4
          , Start.chrysanthemum 2 3
          , Start.sunflower 6 7
          , Start.chrysanthemum 7 2
          ]
        ]


l4StartTiles : List Start.Tile
l4StartTiles =
    List.concat
        [ Start.line (Start.seedPod 1 2) { length = 7, direction = Start.Diagonal Start.BottomRight }
        , Start.line (Start.seedPod 1 3) { length = 7, direction = Start.Diagonal Start.BottomRight }
        , Start.line (Start.seedPod 2 1) { length = 7, direction = Start.Diagonal Start.BottomRight }
        , Start.line (Start.seedPod 3 1) { length = 7, direction = Start.Diagonal Start.BottomRight }
        ]


l5Walls : List Coord
l5Walls =
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


l5StartTiles : List Start.Tile
l5StartTiles =
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


diagonal : List Coord
diagonal =
    toCoords
        [ [ w, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, s, s ]
        , [ s, s, w, s, s, s, s, s ]
        , [ s, s, s, w, s, s, s, s ]
        , [ s, s, s, s, w, s, s, s ]
        , [ s, s, s, s, s, w, s, s ]
        , [ s, s, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, w ]
        ]


l6Walls : List Coord
l6Walls =
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


lWalls : List Coord
lWalls =
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


l7StartTiles : List Start.Tile
l7StartTiles =
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
