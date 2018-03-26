module Config.World.One exposing (world)

import Config.Color exposing (..)
import Config.Tutorial.Rain as RainTutorial
import Config.Tutorial.Seed as SeedTutorial
import Config.Tutorial.SeedPod as SeedPodTutorial
import Config.Tutorial.Square as SquareTutorial
import Config.Tutorial.Sun as SunTutorial
import Config.Wall exposing (..)
import Data.Board.Types exposing (..)
import Data.Board.Wall exposing (toCoords)
import Data.Level.Settings exposing (..)
import Data.Level.Types exposing (..)
import Scenes.Tutorial.Types as Tutorial


world : WorldData Tutorial.Config
world =
    { seedType = Sunflower
    , levels = levels
    , background = yellow
    , textColor = darkYellow
    , textCompleteColor = yellow
    , textBackgroundColor = lightBrown
    }


levels : WorldLevels Tutorial.Config
levels =
    makeWorldLevels
        [ { walls = yellowWalls firstLevelWalls
          , boardDimensions = { x = 5, y = 5 }
          , tutorial = Just SeedTutorial.config
          , moves = 10
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 100)
                    (TargetScore 30)
                ]
          }
        , { walls = yellowWalls secondLevelWalls
          , boardDimensions = { x = 6, y = 6 }
          , tutorial = Just RainTutorial.config
          , moves = 10
          , tileSettings =
                [ seed
                    Sunflower
                    (Probability 50)
                    (TargetScore 10)
                , rain
                    (Probability 50)
                    (TargetScore 10)
                ]
          }
        , { walls = yellowWalls thirdLevelWalls
          , boardDimensions = { x = 6, y = 6 }
          , tutorial = Just SunTutorial.config
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
        , { walls = yellowWalls fourthLevelWalls
          , boardDimensions = { x = 7, y = 7 }
          , moves = 10
          , tutorial = Just SquareTutorial.config
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
          , moves = 10
          , tutorial = Just SeedPodTutorial.config
          , boardDimensions = { x = 7, y = 7 }
          , tileSettings =
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
        , { walls = yellowWalls sixthLevelWalls
          , moves = 20
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
          , moves = 10
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
