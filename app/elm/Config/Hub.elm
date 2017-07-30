module Config.Hub exposing (..)

import Data.Color exposing (orange, yellow)
import Dict
import Model exposing (HubData, WorldData, WorldLevels)
import Scenes.Level.Model exposing (..)


hubData : HubData
hubData =
    Dict.fromList
        [ ( 1, world1 )
        , ( 2, world2 )
        ]


world2 : WorldData
world2 =
    { seedType = Foxglove
    , levels = world1levels
    , background = orange
    }


world1 : WorldData
world1 =
    { seedType = Sunflower
    , levels = world1levels
    , background = yellow
    }


world1levels : WorldLevels
world1levels =
    Dict.fromList
        [ ( 1
          , { tiles = [ Seed, SeedPod ]
            , goal = 100
            }
          )
        , ( 2
          , { tiles = [ Seed, SeedPod, Rain ]
            , goal = 100
            }
          )
        , ( 3
          , { tiles = [ Seed, SeedPod, Rain ]
            , goal = 200
            }
          )
        , ( 4
          , { tiles = [ Seed, SeedPod, Rain ]
            , goal = 500
            }
          )
        , ( 5
          , { tiles = [ Seed, SeedPod, Rain, Sun ]
            , goal = 500
            }
          )
        ]
