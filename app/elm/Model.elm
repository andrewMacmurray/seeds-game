module Model exposing (..)

import Scenes.Level.Model as Level
import Window


type alias Model =
    { scene : Scene
    , transitioning : Bool
    , levelModel : Level.Model
    , window : Window.Size
    }


type Scene
    = Level
    | TitleScreen


type Msg
    = SetScene Scene
    | Transition Bool
    | LevelMsg Level.Msg
    | WindowSize Window.Size


type alias Style =
    ( String, String )
