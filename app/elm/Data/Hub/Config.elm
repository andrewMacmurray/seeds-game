module Data.Hub.Config exposing (..)

import Data.Board.Walls exposing (corners, standardWalls)
import Data.Color exposing (darkYellow, gold, purple, washedYellow, white, yellow)
import Dict
import Model exposing (HubData, WorldData, WorldLevels)
import Scenes.Level.Model exposing (..)


hubData : HubData
hubData =
    Dict.fromList
        [ ( 1, world1 )
        , ( 2, world2 )
        , ( 3, world3 )
        ]


world3 : WorldData
world3 =
    { seedType = Lupin
    , levels = world1levels
    , background = washedYellow
    , textColor = gold
    }


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
        [ ( 1
          , { goal = 100
            , tileProbabilities = [ ( Seed, 25 ), ( SeedPod, 75 ) ]
            , walls = standardWalls
            }
          )
        , ( 2
          , { goal = 100
            , tileProbabilities = [ ( Seed, 30 ), ( SeedPod, 30 ), ( Rain, 30 ) ]
            , walls = standardWalls
            }
          )
        , ( 3
          , { goal = 200
            , tileProbabilities = [ ( Seed, 30 ), ( SeedPod, 30 ), ( Rain, 30 ) ]
            , walls = standardWalls
            }
          )
        , ( 4
          , { goal = 500
            , tileProbabilities = [ ( Seed, 30 ), ( SeedPod, 30 ), ( Rain, 30 ) ]
            , walls = corners
            }
          )
        , ( 5
          , { goal = 500
            , tileProbabilities = [ ( Seed, 25 ), ( SeedPod, 25 ), ( Rain, 25 ), ( Sun, 25 ) ]
            , walls = []
            }
          )
        ]