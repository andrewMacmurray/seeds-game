module Scenes.Level.Types exposing (..)

import Data.Board.Types exposing (Board, Coord, Move, MoveShape, SeedType, TileType, WallColor)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (BoardDimensions, Scores, TileSetting)
import Mouse
import Window


type alias Model =
    { board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , moveShape : Maybe MoveShape
    , tileSettings : List TileSetting
    , boardDimensions : BoardDimensions
    , levelStatus : LevelStatus
    , levelInfoWindow : InfoWindow String
    , successMessageIndex : Int
    , mouse : Mouse.Position
    , window : Window.Size
    }


type Msg
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


type OutMsg
    = ExitLevelWithWin
    | ExitLevelWithLose


type LevelStatus
    = InProgress
    | Lose
    | Win


type alias BoardConfig a =
    { a
        | board : Board
        , boardDimensions : BoardDimensions
    }


type alias TileConfig a =
    { a
        | moveShape : Maybe MoveShape
        , window : Window.Size
        , boardDimensions : BoardDimensions
    }
