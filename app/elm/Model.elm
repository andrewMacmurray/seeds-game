module Model exposing (..)

import Mouse
import Data.Hub.Types exposing (..)
import Scenes.Level.Model as Level
import Scenes.Hub.Model as Hub
import Window


type alias Model =
    { levelModel : Level.Model
    , hubModel : Hub.Model
    , window : Window.Size
    , mouse : Mouse.Position
    , externalAnimations : String
    }


type Msg
    = LevelMsg Level.Msg
    | HubMsg Hub.Msg
    | ReceieveExternalAnimations String
    | StartLevel LevelProgress
    | LoadLevelData ( WorldData, LevelData )
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias HasWindow a =
    { a | window : { height : Int, width : Int } }


type alias Positions a =
    { a
        | window : { height : Int, width : Int }
        , mouse : { y : Int, x : Int }
    }


type alias Style =
    ( String, String )
