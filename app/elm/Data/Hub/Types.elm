module Data.Hub.Types exposing (..)

import Data.Level.Types exposing (..)
import Dict exposing (Dict)


type Scene
    = Level
    | Hub
    | Title


type InfoWindow
    = Visible LevelProgress
    | Leaving LevelProgress
    | Hidden


type TransitionBackground
    = Orange
    | Blue


type alias LevelProgress =
    ( WorldNumber, LevelNumber )


type alias WorldNumber =
    Int


type alias LevelNumber =
    Int


type alias HubData =
    Dict Int WorldData


type alias WorldData =
    { levels : WorldLevels
    , seedType : SeedType
    , background : String
    , textColor : String
    , textCompleteColor : String
    , textBackgroundColor : String
    }


type alias WorldLevels =
    Dict Int LevelData


type alias LevelData =
    { tileProbabilities : List TileProbability
    , walls : List Coord
    , goal : Int
    }
