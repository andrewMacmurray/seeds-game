module Scenes.Level.Types exposing (..)

import Data.Board.Types exposing (..)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (TileSetting)
import Mouse
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
    , hubInfoWindow : InfoWindow String
    , successMessageIndex : Int
    , mouse : Mouse.Position
    , window : Window.Size
    }


type LevelMsg
    = InitTiles (List ( WallColor, Coord )) (List TileType)
    | SquareMove
    | StopMove
    | StartMove Move
    | CheckMove Move
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
    | RandomSuccessMessageIndex Int
    | ShowInfo String
    | RemoveInfo
    | InfoHidden
    | LevelWon
    | LevelLost
    | MousePosition Mouse.Position
    | WindowSize Window.Size


type LevelOutMsg
    = ExitWin
    | ExitLose


type LevelStatus
    = InProgress
    | Lose
    | Win
