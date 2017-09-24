module Model exposing (..)

import Dom
import Mouse
import Data.Hub.Types exposing (..)
import Scenes.Level.Model as Level
import Window


type alias Model =
    { scene : Scene
    , sceneTransition : Bool
    , transitionBackground : TransitionBackground
    , progress : LevelProgress
    , currentLevel : Maybe LevelProgress
    , infoWindow : InfoWindow
    , hubData : HubData
    , levelModel : Level.Model
    , window : Window.Size
    , mouse : Mouse.Position
    , externalAnimations : String
    }


type Msg
    = SetScene Scene
    | BeginSceneTransition
    | EndSceneTransition
    | RandomBackground TransitionBackground
    | ReceieveExternalAnimations String
    | StartLevel LevelProgress
    | SetCurrentLevel (Maybe LevelProgress)
    | LoadLevelData ( WorldData, LevelData )
    | GoToHub
    | ShowInfo LevelProgress
    | HideInfo
    | SetInfoState InfoWindow
    | IncrementProgress
    | ScrollToHubLevel Int
    | ReceiveHubLevelOffset Float
    | DomNoOp (Result Dom.Error ())
    | LevelMsg Level.Msg
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
