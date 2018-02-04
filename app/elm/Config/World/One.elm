module Config.World.One exposing (world)

import Config.Tutorial.Rain as RainTutorial
import Config.Tutorial.Seed as SeedTutorial
import Config.Tutorial.SeedPod as SeedPodTutorial
import Config.Tutorial.Square as SquareTutorial
import Config.Tutorial.Sun as SunTutorial
import Config.Wall exposing (..)
import Data.Color exposing (..)
import Data.Hub.World exposing (..)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (..)


world : WorldData
world =
    { seedType = Sunflower
    , levels = levels
    , background = yellow
    , textColor = darkYellow
    , textCompleteColor = yellow
    , textBackgroundColor = lightBrown
    }


levels : WorldLevels
levels =
    makeWorldLevels
        [ { walls = []
          , boardDimensions = { x = 5, y = 5 }
          , tutorial = Just SeedTutorial.initConfig
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 20)
                    (TargetScore 50)
                ]
          }
        , { walls = []
          , boardDimensions = { x = 5, y = 6 }
          , tutorial = Just RainTutorial.initConfig
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 20)
                    (TargetScore 20)
                , rain
                    (Probability 20)
                    (TargetScore 20)
                ]
          }
        , { walls = []
          , boardDimensions = { x = 6, y = 6 }
          , tutorial = Just SunTutorial.initConfig
          , tileSettings =
                [ rain
                    (Probability 33)
                    (TargetScore 30)
                , seed
                    Sunflower
                    (Probability 33)
                    (TargetScore 30)
                , sun
                    (Probability 33)
                    (TargetScore 30)
                ]
          }
        , { walls = withColor blockYellow <| column 3
          , boardDimensions = { x = 7, y = 7 }
          , tutorial = Just SquareTutorial.initConfig
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 20)
                    (TargetScore 60)
                , rain
                    (Probability 20)
                    (TargetScore 60)
                ]
          }
        , { walls = []
          , tutorial = Just SeedPodTutorial.initConfig
          , boardDimensions = { x = 7, y = 7 }
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 33)
                    (TargetScore 50)
                , rain
                    (Probability 33)
                    (TargetScore 30)
                , seedPod
                    (Probability 33)
                ]
          }
        , { walls = []
          , tutorial = Nothing
          , boardDimensions = { x = 7, y = 7 }
          , tileSettings =
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
        , { walls = []
          , tutorial = Nothing
          , boardDimensions = { x = 8, y = 8 }
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
        ]
