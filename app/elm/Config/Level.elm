module Config.Level exposing (..)

import Config.Wall exposing (..)
import Data.Color exposing (..)
import Dict exposing (Dict)
import Scenes.Hub.Types exposing (AllLevels, LevelData, WorldData, WorldLevels)
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
    , levels = world1levels
    , background = washedYellow
    , textColor = gold
    , textCompleteColor = white
    , textBackgroundColor = gold
    }


world2 : WorldData
world2 =
    { seedType = Foxglove
    , levels = world1levels
    , background = gold
    , textColor = white
    , textCompleteColor = yellow
    , textBackgroundColor = softRed
    }


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
    Dict.fromList
        [ ( 1, { tileSettings = noWeather, walls = withColor blockYellow standardWalls } )
        , ( 2, { tileSettings = noSun, walls = withColor blockYellow standardWalls } )
        , ( 3, { tileSettings = noSun, walls = withColor blockYellow moreWalls } )
        , ( 4, { tileSettings = noRain, walls = withColor blockYellow corners } )
        , ( 5, level5 )
        ]


level5 : LevelData
level5 =
    { tileSettings = evenTiles, walls = [] }


evenTiles : List TileSetting
evenTiles =
    [ ( Rain, 25, Just 40 )
    , ( Seed, 25, Just 100 )
    , ( Sun, 25, Just 40 )
    , ( SeedPod, 25, Nothing )
    ]
        |> List.map addTargetScore


noSun : List TileSetting
noSun =
    [ ( Rain, 33, Just 50 )
    , ( Seed, 33, Just 100 )
    , ( SeedPod, 33, Nothing )
    ]
        |> List.map addTargetScore


noRain : List TileSetting
noRain =
    [ ( Sun, 33, Just 50 )
    , ( Seed, 33, Just 100 )
    , ( SeedPod, 33, Nothing )
    ]
        |> List.map addTargetScore


noWeather : List TileSetting
noWeather =
    [ ( Seed, 25, Just 150 )
    , ( SeedPod, 7, Nothing )
    ]
        |> List.map addTargetScore


addTargetScore : ( TileType, Int, Maybe Int ) -> TileSetting
addTargetScore ( tileType, prob, targetScore ) =
    TileSetting tileType prob targetScore
