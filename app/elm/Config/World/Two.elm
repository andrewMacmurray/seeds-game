module Config.World.Two exposing (world)

import Config.Wall exposing (..)
import Data.Color exposing (..)
import Data.Hub.World exposing (..)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (..)


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
        [ { walls = withColor blockYellow moreWalls
          , boardDimensions = { x = 8, y = 8 }
          , tutorial = Nothing
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
        , { walls = withColor blockYellow corners
          , boardDimensions = { x = 8, y = 8 }
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
        , { walls = withColor blockYellow centerColumns
          , boardDimensions = { x = 8, y = 8 }
          , tutorial = Nothing
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 25)
                    (TargetScore 20)
                , sun
                    (Probability 30)
                    (TargetScore 20)
                , seed
                    Foxglove
                    (Probability 25)
                    (TargetScore 20)
                , seedPod
                    (Probability 40)
                ]
          }
        ]
