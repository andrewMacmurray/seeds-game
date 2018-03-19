module Scenes.Tutorial.Types exposing (..)

import Data2.Board exposing (Board, Coord)
import Data2.Level.Settings exposing (BoardDimensions)
import Data2.Tile exposing (SeedType, TileType)
import Data2.TileState exposing (MoveShape)
import Dict exposing (Dict)
import Window


type alias Model =
    { board : Board
    , boardVisible : Bool
    , textVisible : Bool
    , resourceBankVisible : Bool
    , containerVisible : Bool
    , canvasVisible : Bool
    , skipped : Bool
    , moveShape : Maybe MoveShape
    , resourceBank : TileType
    , boardDimensions : BoardDimensions
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


type OutMsg
    = ExitTutorialToLevel
