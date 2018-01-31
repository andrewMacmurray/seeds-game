module Config.Levels exposing (..)

import Config.Tutorial.Rain as RainTutorial
import Config.Tutorial.Seed as SeedTutorial
import Config.Tutorial.SeedPod as SeedPodTutorial
import Config.Tutorial.Square as SquareTutorial
import Config.Tutorial.Sun as SunTutorial
import Config.Wall exposing (..)
import Data.Color exposing (..)
import Data.Hub.World exposing (..)
import Dict exposing (Dict)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (..)


allLevels : AllLevels
allLevels =
    Dict.fromList
        [ ( 1, world1 )
        , ( 2, world2 )
        , ( 3, world3 )
        ]


world3 : WorldData
world3 =
    { seedType = Lupin
    , levels = world3levels
    , background = washedYellow
    , textColor = gold
    , textCompleteColor = white
    , textBackgroundColor = gold
    }


world3levels : WorldLevels
world3levels =
    makeWorldLevels
        [ { walls = []
          , boardDimensions = { x = 8, y = 8 }
          , tutorial = Nothing
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
        , { walls = withColor blockYellow corners
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


world2 : WorldData
world2 =
    { seedType = Foxglove
    , levels = world2levels
    , background = gold
    , textColor = white
    , textCompleteColor = yellow
    , textBackgroundColor = softRed
    }


world2levels : WorldLevels
world2levels =
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


world1 : WorldData
world1 =
    { seedType = Sunflower
    , levels = world1levels
    , background = yellow
    , textColor = darkYellow
    , textCompleteColor = yellow
    , textBackgroundColor = lightBrown
    }


world1levels : WorldLevels
world1levels =
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


defaultLevel : LevelData
defaultLevel =
    { walls = []
    , boardDimensions = { x = 8, y = 8 }
    , tutorial = Nothing
    , tileSettings =
        [ rain
            (Probability 25)
            (TargetScore 50)
        , seed
            Sunflower
            (Probability 25)
            (TargetScore 100)
        , sun
            (Probability 25)
            (TargetScore 50)
        , seedPod
            (Probability 25)
        ]
    }
