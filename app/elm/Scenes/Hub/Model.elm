module Scenes.Hub.Model exposing (..)

import Data.Hub.Types exposing (..)
import Dom
import Window


type alias Model =
    { scene : Scene
    , sceneTransition : Bool
    , transitionBackground : TransitionBackground
    , progress : LevelProgress
    , currentLevel : Maybe LevelProgress
    , infoWindow : InfoWindow
    , hubData : HubData
    , window : Window.Size
    }


type Msg
    = SetScene Scene
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
    | DomNoOp (Result Dom.Error ())
