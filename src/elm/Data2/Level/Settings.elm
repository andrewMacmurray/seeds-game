module Data2.Level.Settings exposing (..)

import Data2.Block exposing (WallColor)
import Data2.Board exposing (Coord)
import Data2.Tile exposing (SeedType, TileType(..))
import Dict exposing (Dict)
import Helpers.Dict exposing (indexedDictFrom)


type alias Progress =
    ( WorldNumber, LevelNumber )


type alias AllLevels tutorialData =
    Dict WorldNumber (WorldData tutorialData)


type alias CurrentLevelData tutorialData =
    ( WorldData tutorialData, LevelData tutorialData )


type alias WorldNumber =
    Int


type alias WorldData tutorialData =
    { levels : WorldLevels tutorialData
    , seedType : SeedType
    , background : String
    , textColor : String
    , textCompleteColor : String
    , textBackgroundColor : String
    }


type alias WorldLevels tutorialData =
    Dict LevelNumber (LevelData tutorialData)


type alias LevelNumber =
    Int


type alias LevelData tutorialData =
    { tileSettings : List TileSetting
    , walls : List ( WallColor, Coord )
    , boardDimensions : BoardDimensions
    , tutorial : Maybe tutorialData
    , moves : Int
    }


type alias BoardDimensions =
    { x : Int
    , y : Int
    }


type alias TileSetting =
    { tileType : TileType
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int


makeWorldLevels : List (LevelData tutorialConfig) -> WorldLevels tutorialConfig
makeWorldLevels =
    indexedDictFrom 1


rain : Probability -> TargetScore -> TileSetting
rain prob targetScore =
    TileSetting Rain prob (Just targetScore)


sun : Probability -> TargetScore -> TileSetting
sun prob targetScore =
    TileSetting Sun prob (Just targetScore)


seed : SeedType -> Probability -> TargetScore -> TileSetting
seed seedType prob targetScore =
    TileSetting (Seed seedType) prob (Just targetScore)


seedPod : Probability -> TileSetting
seedPod prob =
    TileSetting SeedPod prob Nothing
