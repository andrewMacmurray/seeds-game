module Config.Hub exposing (..)

import Config.Walls exposing (corners, standardWalls)
import Data.Color exposing (darkYellow, gold, white, yellow)
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
    , background = gold
    , textColor = white
    }


world1 : WorldData
world1 =
    { seedType = Sunflower
    , levels = world1levels
    , background = yellow
    , textColor = darkYellow
    }


world1levels : WorldLevels
world1levels =
    Dict.fromList
        [ ( 1, { goal = 100, tiles = [ Seed, SeedPod ], walls = standardWalls } )
        , ( 2, { goal = 100, tiles = [ Seed, SeedPod, Rain ], walls = corners } )
        , ( 3, { goal = 200, tiles = [ Seed, SeedPod, Rain ], walls = standardWalls } )
        , ( 4, { goal = 500, tiles = [ Seed, SeedPod, Rain ], walls = [] } )
        , ( 5, { goal = 500, tiles = [ Seed, SeedPod, Rain, Sun ], walls = [] } )
        ]
