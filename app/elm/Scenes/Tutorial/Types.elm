module Scenes.Tutorial.Types exposing (..)

import Scenes.Level.Types exposing (Board, Coord, MoveShape, SeedType, TileSize, TileType)
import Window


type alias Model =
    { board : Board
    , boardHidden : Bool
    , textHidden : Bool
    , seedBankHidden : Bool
    , containerHidden : Bool
    , canvasHidden : Bool
    , moveShape : Maybe MoveShape
    , tileSize : TileSize
    , seedType : SeedType
    , boardScale : Int
    , topBarHeight : Int
    , text : String
    , window : Window.Size
    }


type Msg
    = DragTile Coord
    | StartSequence
    | SetGrowingPods
    | SetLeavingSeeds
    | GrowPods
    | ResetGrowingPods
    | ResetLeaving
    | AddNewTiles (List TileType)
    | BoardScale Int
    | HideBoard
    | ShowBoard
    | HideText
    | ShowText
    | HideSeedBank
    | ShowSeedBank
    | HideContainer
    | ShowContainer
    | HideCanvas
    | ResetBoard Board
    | TutorialText Int
    | ExitTutorial
