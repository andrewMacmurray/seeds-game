module Model exposing (..)

import Dict exposing (Dict)
import Dom
import Mouse
import Scenes.Level.Model as Level exposing (Coord, SeedType, TileProbability)
import Window


type alias Model =
    { scene : Scene
    , sceneTransition : Bool
    , progress : Progress
    , currentLevel : Maybe Progress
    , hubData : HubData
    , levelModel : Level.Model
    , window : Window.Size
    , mouse : Mouse.Position
    }


type Scene
    = Level
    | Hub
    | Title


type alias Progress =
    ( WorldNumber, LevelNumber )


type alias WorldNumber =
    Int


type alias LevelNumber =
    Int


type alias HubData =
    Dict Int WorldData


type alias WorldData =
    { levels : WorldLevels
    , seedType : SeedType
    , background : String
    , textColor : String
    }


type alias WorldLevels =
    Dict Int LevelData


type alias LevelData =
    { tileProbabilities : List TileProbability
    , walls : List Coord
    , goal : Int
    }


type Msg
    = SetScene Scene
    | Transition Bool
    | StartLevel Progress LevelData
    | SetCurrentLevel (Maybe Progress)
    | LoadLevelData LevelData
    | GoToHub
    | IncrementProgress
    | ScrollToLevel Int
    | ReceiveLevelOffset Float
    | DomNoOp (Result Dom.Error ())
    | LevelMsg Level.Msg
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
