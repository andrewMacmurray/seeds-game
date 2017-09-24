module Scenes.Level.Model exposing (..)

import Data.Level.Types exposing (..)


type alias Model =
    { board : Board
    , scores : Scores
    , isDragging : Bool
    , moveShape : Maybe MoveShape
    , seedType : SeedType
    , tileProbabilities : List TileProbability
    , boardScale : Int
    , scoreIconSize : Int
    , tileSize : TileSize
    , topBarHeight : Int
    }


type Msg
    = InitTiles (List Coord) (List TileType)
    | AddTiles (List TileType)
    | SquareMove
    | StopMove MoveShape
    | StartMove Move
    | CheckMove Move
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | ResetGrowingSeeds
    | MakeNewTiles
    | ResetEntering
    | ShiftBoard
    | ResetMove
