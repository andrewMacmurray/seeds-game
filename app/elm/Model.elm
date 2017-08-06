module Model exposing (..)

import Dict exposing (Dict)
import Dom
import Mouse
import Scenes.Level.Model as Level exposing (Coord, SeedType, TileProbability)
import Window


type alias Model =
    { scene : Scene
    , sceneTransition : Bool
    , progress : LevelProgress
    , currentLevel : Maybe LevelProgress
    , infoWindow : InfoWindow
    , hubData : HubData
    , levelModel : Level.Model
    , window : Window.Size
    , mouse : Mouse.Position
    }


type Scene
    = Level
    | Hub
    | Title


type InfoWindow
    = Visible LevelProgress
    | Leaving LevelProgress
    | Hidden


type alias LevelProgress =
    ( WorldNumber, LevelNumber )


type alias WorldNumber =
    Int


type alias LevelNumber =
    Int


type alias HubData =
    Dict Int WorldData


type alias WorldData =
    { levels : WorldLevels
    , seedType : SeedType
    , background : String
    , textColor : String
    , textCompleteColor : String
    , textBackgroundColor : String
    }


type alias WorldLevels =
    Dict Int LevelData


type alias LevelData =
    { tileProbabilities : List TileProbability
    , walls : List Coord
    , goal : Int
    }


type Msg
    = SetScene Scene
    | Transition Bool
    | StartLevel LevelProgress
    | SetCurrentLevel (Maybe LevelProgress)
    | LoadLevelData ( WorldData, LevelData )
    | GoToHub
    | ShowInfo LevelProgress
    | HideInfo
    | SetInfoState InfoWindow
    | IncrementProgress
    | ScrollToHubLevel Int
    | ReceiveHubLevelOffset Float
    | DomNoOp (Result Dom.Error ())
    | LevelMsg Level.Msg
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
