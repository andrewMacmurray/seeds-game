module Types exposing (..)

import Data.Background exposing (Background)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (LevelData, Progress)
import Data.Visibility exposing (Visibility)
import Scenes.Hub.Types exposing (HubModel, HubMsg)
import Scenes.Intro.Types exposing (IntroModel, IntroMsg)
import Scenes.Level.Types exposing (LevelModel, LevelMsg)
import Scenes.Tutorial.Types exposing (TutorialConfig, TutorialModel, TutorialMsg)
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
    = Title Visibility
    | Level LevelModel
    | Tutorial TutorialModel
    | Intro IntroModel
    | Hub
    | Summary
    | Retry


type Msg
    = LevelMsg LevelMsg
    | TutorialMsg TutorialMsg
    | IntroMsg IntroMsg
    | HubMsg HubMsg
    | StartLevel Progress
    | RestartLevel
    | LevelWin
    | LevelLose
    | LoadTutorial Progress TutorialConfig
    | LoadLevel Progress
    | LoadIntro
    | LoadHub Int
    | LoadSummary
    | LoadRetry
    | FadeTitle
    | CompleteSceneTransition
    | ShowLoadingScreen
    | HideLoadingScreen
    | RandomBackground Background
    | SetCurrentLevel (Maybe Progress)
    | GoToHub
    | GoToIntro
    | IntroMusicPlaying Bool
    | ClearCache
    | WindowSize Window.Size
    | UpdateTimes Time
      -- Summary and Retry
    | IncrementProgress
    | DecrementLives
