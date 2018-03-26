module Types exposing (..)

import Data.Background exposing (Background)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (LevelData, Progress)
import Data.Transit exposing (Transit)
import Dom
import Scenes.Level.Types as Level exposing (..)
import Scenes.Tutorial.Types as Tutorial
import Time exposing (Time)
import Window


type alias Flags =
    { now : Time
    , times : Maybe Times
    , rawProgress : Maybe RawProgress
    }


type alias Times =
    { timeTillNextLife : Time
    , lastPlayed : Time
    }


type alias RawProgress =
    { world : Int
    , level : Int
    }


type alias Model =
    { scene : SceneState
    , loadingScreen : Maybe Background
    , progress : Progress
    , currentLevel : Maybe Progress
    , lives : Transit Int
    , levelInfoWindow : InfoWindow Progress
    , lastPlayed : Time
    , timeTillNextLife : Time
    , window : Window.Size
    , xAnimations : String
    }


type SceneState
    = Transition SceneTransition
    | Loaded Scene


type alias SceneTransition =
    { from : Scene
    , to : Scene
    }


type Scene
    = Title
    | Hub
    | Tutorial Tutorial.Model
    | Level Level.Model
    | Summary
    | Retry


type Msg
    = LevelMsg Level.Msg
    | TutorialMsg Tutorial.Msg
    | StartLevel Progress
    | RestartLevel
    | TransitionWithWin
    | TransitionWithLose
    | LoadTutorial Progress Tutorial.Config
    | LoadLevel Progress
    | LoadHub
    | LoadSummary
    | LoadRetry
    | CompleteSceneTransition
    | ShowLoadingScreen
    | HideLoadingScreen
    | RandomBackground Background
    | SetCurrentLevel (Maybe Progress)
    | GoToHub
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
    | Tick Time


fromProgress : Progress -> RawProgress
fromProgress ( world, level ) =
    RawProgress world level


toProgress : Maybe RawProgress -> Maybe Progress
toProgress =
    Maybe.map toProgress_


toProgress_ : RawProgress -> Progress
toProgress_ { world, level } =
    ( world, level )
