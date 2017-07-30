module Model exposing (..)

import Mouse
import Scenes.Level.Model as Level
import Window


type alias Model =
    { scene : Scene
    , transitioning : Bool
    , levelModel : Level.Model
    , window : Window.Size
    , mouse : Mouse.Position
    }


type Scene
    = Level
    | TitleScreen


type Msg
    = SetScene Scene
    | Transition Bool
    | LevelMsg Level.Msg
    | WindowSize Window.Size
    | MousePosition Mouse.Position


type alias Style =
    ( String, String )
