module Scenes.Hub.Types exposing (..)

import Dict exposing (Dict)
import Dom
import Mouse
import Scenes.Level.Types as Level exposing (..)
import Window


type alias Model =
    { levelModel : Level.Model
    , externalAnimations : String
    , scene : Scene
    , sceneTransition : Bool
    , transitionBackground : TransitionBackground
    , progress : LevelProgress
    , currentLevel : Maybe LevelProgress
    , infoWindow : InfoWindow
    , hubData : HubData
    , window : Window.Size
    , mouse : Mouse.Position
    }


type Msg
    = LevelMsg Level.Msg
    | StartLevel LevelProgress
    | EndLevel
    | LoadLevelData ( WorldData, LevelData )
    | SetScene Scene
    | BeginSceneTransition
    | EndSceneTransition
    | RandomBackground TransitionBackground
    | SetCurrentLevel (Maybe LevelProgress)
    | GoToHub
    | ShowInfo LevelProgress
    | HideInfo
    | SetInfoState InfoWindow
    | IncrementProgress
    | ScrollToHubLevel Int
    | ReceiveHubLevelOffset Float
    | ReceieveExternalAnimations String
    | DomNoOp (Result Dom.Error ())
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type Scene
    = Level
    | Hub
    | Title


type InfoWindow
    = Visible LevelProgress
    | Leaving LevelProgress
    | Hidden


type TransitionBackground
    = Orange
    | Blue


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
    { tileSettings : List TileSetting
    , walls : List Coord
    }
