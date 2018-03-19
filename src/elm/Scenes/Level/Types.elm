module Scenes.Level.Types exposing (..)

import Data.InfoWindow exposing (InfoWindow)
import Data2.Block exposing (WallColor)
import Data2.Board exposing (Board, Coord, Move)
import Data2.Level.Settings exposing (BoardDimensions, TileSetting)
import Data2.Tile exposing (SeedType, TileType)
import Data2.TileState exposing (MoveShape)
import Dict exposing (Dict)
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


type alias Scores =
    Dict String Score


type alias Score =
    { target : Int
    , current : Int
    }


type LevelStatus
    = InProgress
    | Lose
    | Win


type alias HasBoard a =
    { a | board : Board }


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
