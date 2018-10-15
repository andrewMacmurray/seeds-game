module Types exposing
    ( Flags
    , Model
    , Msg(..)
    )

import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (LevelData, Progress)
import Data.Lives as Lives
import Data.Visibility exposing (Visibility)
import Data.Window as Window
import Ports exposing (RawProgress)
import Scene exposing (Scene)
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial
import Shared exposing (Background)
import Time exposing (Posix)


type alias Flags =
    { now : Int
    , lives : Maybe Lives.Cache
    , rawProgress : Maybe RawProgress
    , randomMessageIndex : Int
    , window : Window.Size
    }


type alias Model =
    { scene : Scene
    }


type Msg
    = TitleMsg Title.Msg
    | LevelMsg Level.Msg
    | TutorialMsg Tutorial.Msg
    | IntroMsg Intro.Msg
    | HubMsg Hub.Msg
    | IncrementSuccessMessageIndex
    | StartLevel Progress
    | RestartLevel
    | LevelWin
    | LevelLose
    | LoadTutorial Tutorial.Config
    | LoadLevel Progress
    | LoadIntro
    | LoadHub Int
    | LoadSummary
    | LoadRetry
    | ShowLoadingScreen
    | HideLoadingScreen
    | RandomBackground Background
    | SetCurrentLevel (Maybe Progress)
    | GoToHub
    | ClearCache
    | WindowSize Int Int
    | UpdateTimes Posix
    | IncrementProgress
    | DecrementLives
