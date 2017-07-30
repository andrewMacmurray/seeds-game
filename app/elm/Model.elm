module Model exposing (..)

import Dict exposing (Dict)
import Mouse
import Scenes.Level.Model as Level exposing (Coord, SeedType, TileType)
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
    | Hub
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
    , textColor : String
    }


type alias WorldLevels =
    Dict Int LevelData


type alias LevelData =
    { tiles : List TileType
    , walls : List Coord
    , goal : Int
    }


type Msg
    = SetScene Scene
    | Transition Bool
    | StartLevel LevelData
    | LoadLevelData LevelData
    | GoToHub
    | IncrementProgress
    | LevelMsg Level.Msg
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
