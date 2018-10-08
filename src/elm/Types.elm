module Types exposing
    ( Flags
    , Model
    , Msg(..)
    )

import Data.Background exposing (Background)
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (LevelData, Progress)
import Data.Visibility exposing (Visibility)
import Data.Window as Window
import Ports exposing (RawProgress, Times)
import Scene exposing (Scene)
import Scenes.Hub.Types exposing (HubModel, HubMsg)
import Scenes.Intro.Types exposing (IntroModel, IntroMsg)
import Scenes.Level.Types exposing (LevelModel, LevelMsg)
import Scenes.Title as Title
import Scenes.Tutorial.Types exposing (TutorialConfig, TutorialModel, TutorialMsg)
import Shared
import Time exposing (Posix)


type alias Flags =
    { now : Float
    , times : Maybe Times
    , rawProgress : Maybe RawProgress
    , randomMessageIndex : Int
    , window : Window.Size
    }


type alias Model =
    { scene : Scene
    }


type Msg
    = TitleMsg Title.Msg
    | LevelMsg LevelMsg
    | TutorialMsg TutorialMsg
    | IntroMsg IntroMsg
    | HubMsg HubMsg
    | IncrementSuccessMessageIndex
    | StartLevel Progress
    | RestartLevel
    | LevelWin
    | LevelLose
    | LoadTutorial TutorialConfig
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
