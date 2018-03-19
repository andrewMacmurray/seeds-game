module Config.World.Two exposing (world)

import Config.Color exposing (..)
import Config.Wall exposing (..)
import Data.Hub.World exposing (..)
import Data2.Board exposing (Coord)
import Data2.Level.Settings exposing (..)
import Data2.Tile exposing (..)
import Scenes.Hub.Types exposing (..)


world : WorldData
world =
    { seedType = Foxglove
    , levels = levels
    , background = gold
    , textColor = white
    , textCompleteColor = yellow
    , textBackgroundColor = softRed
    }


levels : WorldLevels
levels =
    makeWorldLevels
        [ { walls = yellowWalls borders
          , boardDimensions = { x = 8, y = 8 }
          , tutorial = Nothing
          , moves = 10
          , tileSettings =
                [ seed
                    Foxglove
                    (Probability 50)
                    (TargetScore 50)
                , sun
                    (Probability 50)
                    (TargetScore 30)
                , seedPod
                    (Probability 30)
                ]
          }
        , { walls = yellowWalls corners
          , boardDimensions = { x = 8, y = 8 }
          , moves = 10
          , tutorial = Nothing
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 25)
                    (TargetScore 30)
                , rain
                    (Probability 25)
                    (TargetScore 20)
                , seed
                    Foxglove
                    (Probability 25)
                    (TargetScore 30)
                , seedPod
                    (Probability 25)
                ]
          }
        , { walls = yellowWalls innerBorders
          , boardDimensions = { x = 8, y = 8 }
          , moves = 10
          , tutorial = Nothing
          , tileSettings =
                [ rain
                    (Probability 20)
                    (TargetScore 20)
                , seed
                    Foxglove
                    (Probability 20)
                    (TargetScore 50)
                , sun
                    (Probability 20)
                    (TargetScore 20)
                , seedPod
                    (Probability 40)
                ]
          }
        , { walls = yellowWalls fourthLevelWalls
          , boardDimensions = { x = 7, y = 8 }
          , moves = 10
          , tutorial = Nothing
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 25)
                    (TargetScore 50)
                , seed
                    Foxglove
                    (Probability 25)
                    (TargetScore 50)
                , seedPod
                    (Probability 40)
                ]
          }
        , { walls = yellowWalls centerColumns
          , boardDimensions = { x = 8, y = 8 }
          , moves = 10
          , tutorial = Nothing
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
                    Foxglove
                    (Probability 25)
                    (TargetScore 20)
                ]
          }
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
