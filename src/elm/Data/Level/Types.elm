module Data.Level.Types exposing (..)

import Data.Board.Types exposing (BoardDimensions, Coord, SeedType, TileType, WallColor)
import Dict exposing (Dict)


type alias Progress =
    ( WorldNumber, LevelNumber )


type alias AllLevels tutorialData =
    Dict WorldNumber (WorldData tutorialData)


type alias CurrentLevelConfig tutorialData =
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


type alias TileSetting =
    { tileType : TileType
    , probability : Probability
    , targetScore : Maybe TargetScore
    }


type TargetScore
    = TargetScore Int


type Probability
    = Probability Int
