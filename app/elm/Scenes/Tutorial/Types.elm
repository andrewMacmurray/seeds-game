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
    , moveShape : Maybe MoveShape
    , tileSize : TileSize
    , resourceBank : TileType
    , boardDimensions : BoardDimensions
    , topBarHeight : Int
    , currentText : Int
    , text : Dict Int String
    , window : Window.Size
    }


type alias InitConfig =
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
    | StartSequence InitConfig
    | SetGrowingPods
    | SetLeaving
    | ResetLeaving
    | GrowPods
    | ResetGrowingPods
    | EnteringTiles (List TileType)
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
    | NextText
    | ExitTutorial
