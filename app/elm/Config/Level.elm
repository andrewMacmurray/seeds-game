module Config.Level exposing (..)

import Config.Wall exposing (..)
import Data.Color exposing (..)
import Dict exposing (Dict)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (..)
import Data.Hub.World exposing (..)


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
          , tileSettings =
                [ rain 20 30
                , seed Lupin 50 30
                , seedPod 30
                ]
          }
        , { walls = withColor blockYellow corners
          , tileSettings =
                [ seed Sunflower 25 30
                , seed Lupin 25 30
                , rain 25 40
                , seedPod 25
                ]
          }
        , { walls = []
          , tileSettings =
                [ seed Foxglove 25 30
                , seed Lupin 25 30
                , seed Sunflower 25 30
                , rain 25 30
                , seedPod 25
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
        [ { walls = withColor blockYellow corners
          , tileSettings =
                [ seed Foxglove 50 30
                , sun 20 30
                , seedPod 30
                ]
          }
        , { walls = []
          , tileSettings =
                [ seed Sunflower 25 30
                , seed Foxglove 25 30
                , rain 25 40
                , seedPod 25
                ]
          }
        , { walls = withColor blockYellow centerColumns
          , tileSettings =
                [ seed Sunflower 25 30
                , seed Foxglove 25 30
                , sun 25 40
                , seedPod 25
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
        [ { walls = withColor blockYellow standardWalls
          , tileSettings =
                [ seed Sunflower 20 150
                , seedPod 50
                ]
          }
        , { walls = withColor blockYellow standardWalls
          , tileSettings =
                [ seed Sunflower 33 100
                , rain 33 50
                , seedPod 33
                ]
          }
        , { walls = withColor blockYellow centerColumns
          , tileSettings =
                [ seed Sunflower 33 100
                , rain 33 50
                , seedPod 33
                ]
          }
        , { walls = withColor blockYellow corners
          , tileSettings =
                [ seed Sunflower 33 100
                , sun 33 50
                , seedPod 33
                ]
          }
        , { walls = []
          , tileSettings =
                [ rain 25 50
                , seed Sunflower 25 100
                , sun 25 50
                , seedPod 25
                ]
          }
        ]


defaultLevel : LevelData
defaultLevel =
    { walls = []
    , tileSettings =
        [ rain 25 50
        , seed Sunflower 25 100
        , sun 25 50
        , seedPod 25
        ]
    }
