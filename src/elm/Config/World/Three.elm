module Config.World.Three exposing (world)

import Config.Wall exposing (..)
import Config.Color exposing (..)
import Data.Hub.World exposing (..)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (..)


world : WorldData
world =
    { seedType = Lupin
    , levels = levels
    , background = washedYellow
    , textColor = gold
    , textCompleteColor = white
    , textBackgroundColor = gold
    }


levels : WorldLevels
levels =
    makeWorldLevels
        [ { walls = yellowWalls firstLevelWalls
          , boardDimensions = { x = 6, y = 8 }
          , tutorial = Nothing
          , moves = 10
          , tileSettings =
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
        , { walls = yellowWalls corners
          , moves = 10
          , boardDimensions = { x = 8, y = 8 }
          , tutorial = Nothing
          , tileSettings =
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
        , { walls = []
          , moves = 10
          , boardDimensions = { x = 8, y = 8 }
          , tutorial = Nothing
          , tileSettings =
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
