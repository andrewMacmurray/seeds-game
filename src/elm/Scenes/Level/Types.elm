module Scenes.Level.Types exposing (..)

import Data.Board.Types exposing (..)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (TileSetting)
import Window


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
    = InitTiles (List ( WallColor, Coord )) (List TileType)
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
    | WindowSize Window.Size


type alias Position =
    { x : Int
    , y : Int
    }


type LevelOutMsg
    = ExitWin
    | ExitLose


type LevelStatus
    = InProgress
    | Lose
    | Win
