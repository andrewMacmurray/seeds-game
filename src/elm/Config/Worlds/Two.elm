module Config.Worlds.Two exposing (world)

import Board.Coord exposing (Coord)
import Board.Wall exposing (..)
import Config.Levels as Levels
import Css.Color as Color
import Level.Setting.Start as Start
import Level.Setting.Tile exposing (..)
import Seed exposing (Seed(..))


world : Levels.World
world =
    Levels.world
        { seed = Chrysanthemum
        , backdropColor = Color.gold
        , textColor = Color.white
        , textCompleteColor = Color.yellow
        , textBackgroundColor = Color.softRed
        }
        levels


levels : List Levels.Level
levels =
    [ Levels.withTutorial Levels.SeedPod
        { walls = walls firstLevelWalls
        , startTiles = []
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
    , Levels.level
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
    , Levels.level
        { walls = walls thirdLevelWalls
        , startTiles = thirdLevelStartTiles
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
    , Levels.level
        { walls = walls fourthLevelWalls
        , startTiles = fourthLevelStartTiles
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
    , Levels.level
        { walls = walls fifthLevelWalls
        , startTiles = fifthLevelStartTiles
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


thirdLevelWalls : List Coord
thirdLevelWalls =
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


thirdLevelStartTiles : List Start.Tile
thirdLevelStartTiles =
    List.concat
        [ Start.square (Start.seed Chrysanthemum 3 3) { size = 4 }
        , Start.corner (Start.sun 1 1) { size = 3, facing = Start.BottomRight }
        , Start.corner (Start.sun 8 1) { size = 3, facing = Start.BottomLeft }
        , Start.corner (Start.rain 1 8) { size = 3, facing = Start.TopRight }
        , Start.corner (Start.rain 8 8) { size = 3, facing = Start.TopLeft }
        , [ Start.burst 3 3
          , Start.burst 6 6
          ]
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


fourthLevelStartTiles : List Start.Tile
fourthLevelStartTiles =
    [ Start.burst 4 1
    , Start.burst 4 2
    , Start.burst 4 7
    , Start.burst 4 8
    ]


fifthLevelWalls : List Coord
fifthLevelWalls =
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


fifthLevelStartTiles : List Start.Tile
fifthLevelStartTiles =
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
