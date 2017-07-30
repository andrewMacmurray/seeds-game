module Model exposing (..)

import Dict exposing (Dict)
import Mouse
import Scenes.Level.Model as Level exposing (TileType, SeedType)
import Window


type alias Model =
    { scene : Scene
    , sceneTransition : Bool
    , progress : Progress
    , hubData : HubData
    , levelModel : Level.Model
    , window : Window.Size
    , mouse : Mouse.Position
    }


type Scene
    = Level
    | TitleScreen


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
    }


type alias WorldLevels =
    Dict Int LevelData


type alias LevelData =
    { tiles : List TileType
    , goal : Int
    }


type Msg
    = SetScene Scene
    | Transition Bool
    | StartLevel
    | IncrementProgress
    | LevelMsg Level.Msg
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
