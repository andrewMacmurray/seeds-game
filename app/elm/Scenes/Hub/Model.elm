module Scenes.Hub.Model exposing (..)

import Data.Hub.Types exposing (..)
import Mouse
import Scenes.Level.Model as Level
import Window
import Dom


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
