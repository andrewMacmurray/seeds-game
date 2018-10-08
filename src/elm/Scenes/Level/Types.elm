module Scenes.Level.Types exposing (LevelModel, LevelMsg(..), LevelStatus(..), Position)

import Css.Color exposing (Color)
import Data.Board.Types exposing (..)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (TileSetting)
import Data.Window as Window
import Shared


type alias LevelModel =
    { shared : Shared.Data
    , board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , moveShape : Maybe MoveShape
    , tileSettings : List TileSetting
    , boardDimensions : BoardDimensions
    , levelStatus : LevelStatus
    , infoWindow : InfoWindow String
    , pointerPosition : Position
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


type alias Position =
    { x : Int
    , y : Int
    }


type LevelStatus
    = InProgress
    | Lose
    | Win
