module Scenes.Hub.Types exposing (..)

import Dict exposing (Dict)
import Dom
import Mouse
import Scenes.Level.Types as Level exposing (..)
import Scenes.Tutorial.Types as Tutorial
import Window


type alias Model =
    { levelModel : Level.Model
    , tutorialModel : Tutorial.Model
    , externalAnimations : String
    , scene : Scene
    , sceneTransition : Bool
    , transitionBackground : TransitionBackground
    , progress : LevelProgress
    , currentLevel : Maybe LevelProgress
    , infoWindow : InfoWindow
    , window : Window.Size
    , mouse : Mouse.Position
    }


type Msg
    = LevelMsg Level.Msg
    | TutorialMsg Tutorial.Msg
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
    | Tutorial


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


type alias AllLevels =
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
    , walls : List ( WallColor, Coord )
    , boardScale : BoardScale
    }
