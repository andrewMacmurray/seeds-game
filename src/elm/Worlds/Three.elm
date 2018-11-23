module Worlds.Three exposing (world)

import Css.Color as Color
import Data.Board.Types exposing (Coord, SeedType(..))
import Data.Board.Wall exposing (..)
import Data.Level.Settings exposing (rain, seed, seedPod, sun)
import Data.Level.Types exposing (..)
import Data.Levels as Levels


world : Levels.World
world =
    Levels.world
        { seedType = Lupin
        , backdropColor = Color.softRed
        , textColor = Color.white
        , textCompleteColor = Color.white
        , textBackgroundColor = Color.gold
        }
        levels


levels : List Levels.Level
levels =
    [ Levels.level
        { walls = yellowWalls firstLevelWalls
        , boardDimensions = { x = 6, y = 8 }
        , moves = 20
        , tiles =
            [ rain
                (Probability 20)
                (TargetScore 50)
            , seed
                Lupin
                (Probability 20)
                (TargetScore 100)
            , seedPod
                (Probability 40)
            ]
        }
    , Levels.level
        { walls = yellowWalls corners
        , moves = 10
        , boardDimensions = { x = 8, y = 8 }
        , tiles =
            [ seed
                Sunflower
                (Probability 25)
                (TargetScore 30)
            , seed
                Lupin
                (Probability 25)
                (TargetScore 30)
            , rain
                (Probability 25)
                (TargetScore 40)
            , seedPod
                (Probability 25)
            ]
        }
    , Levels.level
        { walls = []
        , moves = 15
        , boardDimensions = { x = 8, y = 8 }
        , tiles =
            [ seed
                Foxglove
                (Probability 25)
                (TargetScore 30)
            , seed
                Lupin
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
            ]
        }
    ]


firstLevelWalls : List Coord
firstLevelWalls =
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
