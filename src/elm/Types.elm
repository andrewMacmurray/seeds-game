module Types exposing
    ( Flags
    , Model
    , Msg(..)
    )

import Data.Levels as Levels
import Data.Lives as Lives
import Scene exposing (Scene)
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial
import Shared exposing (Background, Window)
import Time


type alias Flags =
    { now : Int
    , lives : Maybe Lives.Cache
    , level : Maybe Levels.Cache
    , randomMessageIndex : Int
    , window : Window
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
    | StartLevel Levels.Key
    | RestartLevel
    | LevelWin
    | LevelLose
    | LoadTutorial Tutorial.Config
    | LoadLevel Levels.LevelConfig
    | LoadIntro
    | LoadHub Levels.Key
    | LoadSummary
    | LoadRetry
    | ShowLoadingScreen
    | HideLoadingScreen
    | RandomBackground Background
    | SetCurrentLevel (Maybe Levels.Key)
    | GoToHub
    | ClearCache
    | WindowSize Int Int
    | UpdateTimes Time.Posix
    | IncrementProgress
    | DecrementLives
