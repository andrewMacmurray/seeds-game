module Model exposing (..)

import Mouse
import Data.Hub.Types exposing (..)
import Scenes.Level.Model exposing (LevelModel, LevelMsg)
import Scenes.Hub.Model exposing (HubModel, HubMsg)
import Window


type alias Model =
    { levelModel : LevelModel
    , hubModel : HubModel
    , window : Window.Size
    , mouse : Mouse.Position
    , externalAnimations : String
    }


type Msg
    = LevelMsg LevelMsg
    | HubMsg HubMsg
    | ReceieveExternalAnimations String
    | StartLevel LevelProgress
    | LoadLevelData ( WorldData, LevelData )
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
