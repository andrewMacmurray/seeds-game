module Scenes.Tutorial.Types exposing (..)

import Data.Board.Types exposing (Board, BoardDimensions, Coord, MoveShape, SeedType, TileType)
import Dict exposing (Dict)
import Scenes.Level.Types exposing (LevelModel, LevelMsg)
import Window


type alias TutorialModel =
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
    , levelModel : LevelModel
    }


type alias TutorialConfig =
    { text : Dict Int String
    , boardDimensions : BoardDimensions
    , board : Board
    , resourceBank : TileType
    , sequence : Sequence
    }


type alias Sequence =
    List ( Float, TutorialMsg )


type TutorialMsg
    = LevelMsg LevelMsg
    | DragTile Coord
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
    | WindowSize Window.Size
