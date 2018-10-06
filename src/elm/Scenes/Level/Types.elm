module Scenes.Level.Types exposing (LevelModel, LevelMsg(..), LevelStatus(..), Position)

import Css.Color exposing (Color)
import Data.Board.Types exposing (..)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (TileSetting)
import Data.Window as Window


type alias LevelModel =
    { board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , moveShape : Maybe MoveShape
    , tileSettings : List TileSetting
    , boardDimensions : BoardDimensions
    , levelStatus : LevelStatus
    , infoWindow : InfoWindow String
    , successMessageIndex : Int
    , pointerPosition : Position
    , window : Window.Size
    }


type LevelMsg
    = InitTiles (List ( Color, Coord )) (List TileType)
    | SquareMove
    | StopMove
    | StartMove Move Position
    | CheckMove Position
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | InsertGrowingSeeds SeedType
    | ResetGrowingSeeds
    | GenerateEnteringTiles
    | InsertEnteringTiles (List TileType)
    | ResetEntering
    | ShiftBoard
    | ResetMove
    | CheckLevelComplete
    | ShowInfo String
    | RemoveInfo
    | InfoHidden
    | LevelWon
    | LevelLost
    | WindowSize Int Int


type alias Position =
    { x : Int
    , y : Int
    }


type LevelStatus
    = InProgress
    | Lose
    | Win
