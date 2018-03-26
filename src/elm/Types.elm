module Types exposing (..)

import Data.Background exposing (Background)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (LevelData, Progress)
import Scenes.Level.Types exposing (LevelModel, LevelMsg)
import Scenes.Tutorial.Types exposing (TutorialModel, TutorialMsg, TutorialConfig)
import Scenes.Hub.Types exposing (HubModel, HubMsg)
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
    , timeTillNextLife : Time
    , lastPlayed : Time
    , hubInfoWindow : InfoWindow Progress
    , window : Window.Size
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
    | Tutorial TutorialModel
    | Level LevelModel
    | Summary
    | Retry


type Msg
    = LevelMsg LevelMsg
    | TutorialMsg TutorialMsg
    | HubMsg HubMsg
    | StartLevel Progress
    | RestartLevel
    | TransitionWithWin
    | TransitionWithLose
    | LoadTutorial Progress TutorialConfig
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
    | ClearCache
    | WindowSize Window.Size
    | UpdateTimes Time
      -- Summary and Retry Specific Messages
    | IncrementProgress
    | DecrementLives
