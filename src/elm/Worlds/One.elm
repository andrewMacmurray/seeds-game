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
        { walls = Wall.walls firstLevelWalls
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
        { walls = Wall.walls secondLevelWalls
        , startTiles = []
        , boardDimensions = { x = 6, y = 6 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 50)
                (TargetScore 20)
            , rain
                (Probability 50)
                (TargetScore 20)
            ]
        }
    , Levels.withTutorial Levels.Sun
        { walls = Wall.walls thirdLevelWalls
        , startTiles = []
        , boardDimensions = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ rain
                (Probability 33)
                (TargetScore 10)
            , seed
                Sunflower
                (Probability 33)
                (TargetScore 10)
            , sun
                (Probability 33)
                (TargetScore 10)
            ]
        }
    , Levels.level
        { walls = Wall.walls fourthLevelWalls
        , startTiles = []
        , boardDimensions = { x = 7, y = 7 }
        , moves = 10
        , tileSettings =
            [ seed
                Sunflower
                (Probability 20)
                (TargetScore 30)
            , rain
                (Probability 20)
                (TargetScore 30)
            ]
        }
    , Levels.level
        { walls = Wall.walls fifthLevelWalls
        , startTiles = fifthLevelStartTiles
        , moves = 10
        , boardDimensions = { x = 8, y = 8 }
        , tileSettings =
            [ seed
                Sunflower
                (Probability 50)
                (TargetScore 100)
            , sun
                (Probability 50)
                (TargetScore 100)
            , burst
                (Probability 1)
            ]
        }
    , Levels.level
        { walls = Wall.walls sixthLevelWalls
        , moves = 20
        , startTiles = sixthLevelStartTiles
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


firstLevelWalls : List Coord
firstLevelWalls =
    Wall.toCoords
        [ [ s, s, s, s, s ]
        , [ s, s, s, s, s ]
        , [ s, w, s, w, s ]
        , [ s, s, s, s, s ]
        , [ s, s, s, s, s ]
        ]


secondLevelWalls : List Coord
secondLevelWalls =
    Wall.toCoords
        [ [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        ]


thirdLevelWalls : List Coord
thirdLevelWalls =
    Wall.toCoords
        [ [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, w, s, w, s, s ]
        , [ s, s, s, s, s, s, s ]
        ]


fourthLevelWalls : List Coord
fourthLevelWalls =
    Wall.toCoords
        [ [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        ]


fifthLevelWalls : List Coord
fifthLevelWalls =
    Wall.toCoords
        [ [ s, w, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, s, s ]
        , [ s, w, s, w, s, w, w, w ]
        , [ s, s, s, w, s, s, s, s ]
        , [ s, s, s, w, s, s, s, s ]
        , [ s, w, s, w, s, w, w, w ]
        , [ s, w, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


fifthLevelStartTiles : List Start.Tile
fifthLevelStartTiles =
    [ Start.sun 4 3
    , Start.burst 5 3
    , Start.seed Sunflower 4 4
    , Start.seed Sunflower 5 4
    , Start.burst 3 5
    ]


sixthLevelWalls : List Coord
sixthLevelWalls =
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


sixthLevelStartTiles : List Start.Tile
sixthLevelStartTiles =
    [ Start.burst 4 5
    , Start.burst 5 4
    ]
