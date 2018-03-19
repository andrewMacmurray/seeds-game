module Scenes.Hub.Types exposing (..)

import Data.InfoWindow exposing (InfoWindow)
import Data.Transit exposing (Transit)
import Data2.Level.Settings exposing (BoardDimensions, LevelData, Progress, TileSetting)
import Dom
import Mouse
import Scenes.Level.Types as Level exposing (..)
import Scenes.Tutorial.Types as Tutorial
import Time exposing (Time)
import Window


type alias Model =
    { levelModel : Level.Model
    , tutorialModel : Tutorial.Model
    , xAnimations : String
    , scene : Scene
    , sceneTransition : Bool
    , transitionBackground : TransitionBackground
    , progress : Progress
    , currentLevel : Maybe Progress
    , lives : Transit Int
    , infoWindow : InfoWindow Progress
    , window : Window.Size
    , mouse : Mouse.Position
    , lastPlayed : Time
    , timeTillNextLife : Time
    }


type Msg
    = LevelMsg Level.Msg
    | TutorialMsg Tutorial.Msg
    | StartLevel Progress
    | RestartLevel
    | TransitionWithWin
    | TransitionWithLose
    | LoadLevelData (LevelData Tutorial.Config)
    | SetScene Scene
    | BeginSceneTransition
    | EndSceneTransition
    | RandomBackground TransitionBackground
    | SetCurrentLevel (Maybe Progress)
    | GoToHub
    | GoToRetry
    | ShowInfo Progress
    | HideInfo
    | SetInfoState (InfoWindow Progress)
    | IncrementProgress
    | DecrementLives
    | ScrollToHubLevel Int
    | ReceiveHubLevelOffset Float
    | ReceieveExternalAnimations String
    | ClearCache
    | DomNoOp (Result Dom.Error ())
    | WindowSize Window.Size
    | MousePosition Mouse.Position
    | Tick Time


type Scene
    = Level
    | Hub
    | Title
    | Tutorial
    | Summary
    | Retry


type TransitionBackground
    = Orange
    | Blue
