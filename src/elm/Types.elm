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
    { scene : Scene
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


type Scene
    = Title
    | Hub
    | Tutorial Tutorial.Model (Backdrop Level.Model)
    | Level Level.Model
    | Summary (Backdrop Level.Model)
    | Retry (Backdrop Level.Model)


type Backdrop a
    = Backdrop a


type Msg
    = LevelMsg Level.Msg
    | TutorialMsg Tutorial.Msg
    | StartLevel Progress
    | RestartLevel
    | TransitionWithWin
    | TransitionWithLose
    | LoadTutorial Progress Tutorial.Config
    | LoadLevel (LevelData Tutorial.Config)
    | LoadHub
    | LoadSummary
    | LoadRetry
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
