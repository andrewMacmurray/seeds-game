module Scenes.Tutorial.Types exposing (..)

import Scenes.Level.Types exposing (Board, Coord, MoveShape, SeedType, TileSize)


type alias Model =
    { board : Board
    , boardHidden : Bool
    , moveShape : Maybe MoveShape
    , tileSize : TileSize
    , seedType : SeedType
    , boardScale : Int
    }


type Msg
    = DragTile Coord Int
    | GrowSeedPodsSequence
    | SetGrowingPods
    | GrowPods
    | ResetGrowingPods
    | DragSequence
    | ShowBoard
    | HideBoard
    | ResetBoard
