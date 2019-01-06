module Worlds.One exposing (default, world)

import Css.Color as Color
import Data.Board.Types exposing (Coord, SeedType(..))
import Data.Board.Wall exposing (..)
import Data.Level.Setting exposing (..)
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
        { walls = yellowWalls firstLevelWalls
        , boardDimensions = { x = 5, y = 5 }
        , moves = 10
        , tiles =
            [ seed
                Sunflower
                (Probability 100)
                (TargetScore 30)
            ]
        }
    , Levels.withTutorial Levels.Rain
        { walls = yellowWalls secondLevelWalls
        , boardDimensions = { x = 6, y = 6 }
        , moves = 10
        , tiles =
            [ seed
                Sunflower
                (Probability 50)
                (TargetScore 10)
            , rain
                (Probability 50)
                (TargetScore 10)
            ]
        }
    , Levels.withTutorial Levels.Sun
        { walls = yellowWalls thirdLevelWalls
        , boardDimensions = { x = 6, y = 6 }
        , moves = 10
        , tiles =
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
        { walls = yellowWalls fourthLevelWalls
        , boardDimensions = { x = 7, y = 7 }
        , moves = 10
        , tiles =
            [ seed
                Sunflower
                (Probability 20)
                (TargetScore 60)
            , rain
                (Probability 20)
                (TargetScore 60)
            ]
        }
    , Levels.withTutorial Levels.SeedPod
        { walls = []
        , moves = 10
        , boardDimensions = { x = 7, y = 7 }
        , tiles =
            [ seed
                Sunflower
                (Probability 5)
                (TargetScore 50)
            , sun
                (Probability 45)
                (TargetScore 30)
            , seedPod
                (Probability 45)
            ]
        }
    , Levels.level
        { walls = yellowWalls sixthLevelWalls
        , moves = 20
        , boardDimensions = { x = 7, y = 7 }
        , tiles =
            [ seed
                Sunflower
                (Probability 33)
                (TargetScore 100)
            , sun
                (Probability 33)
                (TargetScore 50)
            , seedPod
                (Probability 33)
            ]
        }
    , Levels.level
        { walls = []
        , moves = 10
        , boardDimensions = { x = 8, y = 8 }
        , tiles =
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
        , tiles =
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
    toCoords
        [ [ s, s, s, s, s ]
        , [ w, w, w, w, s ]
        , [ s, s, s, s, s ]
        , [ s, w, w, w, w ]
        , [ s, s, s, s, s ]
        ]


secondLevelWalls : List Coord
secondLevelWalls =
    toCoords
        [ [ s, s, s, s, s, s ]
        , [ s, s, w, w, w, w ]
        , [ s, s, s, s, s, s ]
        , [ w, w, w, w, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, w, w, w, w ]
        ]


thirdLevelWalls : List Coord
thirdLevelWalls =
    toCoords
        [ [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        , [ s, s, s, s, s, s ]
        , [ s, w, s, s, w, s ]
        , [ s, s, s, s, s, s ]
        ]


fourthLevelWalls : List Coord
fourthLevelWalls =
    toCoords
        [ [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        , [ s, s, s, w, s, s, s ]
        ]


sixthLevelWalls : List Coord
sixthLevelWalls =
    toCoords
        [ [ w, s, s, w, s, s, w ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s ]
        , [ w, s, s, w, s, s, w ]
        ]
