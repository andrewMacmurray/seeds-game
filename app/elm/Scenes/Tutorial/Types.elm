module Scenes.Tutorial.Types exposing (..)

import Scenes.Level.Types exposing (Board, Coord, MoveShape, SeedType, TileSize, TileType, BoardDimensions)
import Window
import Dict exposing (Dict)


type alias Model =
    { board : Board
    , boardVisible : Bool
    , textVisible : Bool
    , resourceBankVisible : Bool
    , containerVisible : Bool
    , canvasVisible : Bool
    , skipped : Bool
    , moveShape : Maybe MoveShape
    , tileSize : TileSize
    , resourceBank : TileType
    , boardDimensions : BoardDimensions
    , topBarHeight : Int
    , currentText : Int
    , text : Dict Int String
    , window : Window.Size
    }


type alias Config =
    { text : Dict Int String
    , boardDimensions : BoardDimensions
    , board : Board
    , resourceBank : TileType
    , sequence : Sequence
    }


type alias Sequence =
    List ( Float, Msg )


type Msg
    = DragTile Coord
    | StartSequence Config
    | SetGrowingPods
    | SetLeaving
    | ResetLeaving
    | GrowPods SeedType
    | ResetGrowingPods
    | EnteringTiles (List TileType)
    | TriggerSquare
    | FallTiles
    | ShiftBoard
    | SetBoardDimensions BoardDimensions
    | HideBoard
    | ShowBoard
    | HideText
    | ShowText
    | HideResourceBank
    | ShowResourceBank
    | HideContainer
    | ShowContainer
    | HideCanvas
    | ResetBoard Board
    | ResetVisibilities
    | NextText
    | SkipTutorial
    | DisableTutorial
    | ExitTutorial
