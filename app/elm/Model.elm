module Model exposing (..)

import Scenes.Level.Model as Level


type alias Model =
    { scene : Scene
    , transitioning : Bool
    , levelModel : Level.Model
    }


type Scene
    = Level
    | TitleScreen


type Msg
    = SetScene Scene
    | Transition Bool
    | LevelMsg Level.Msg


type alias Style =
    ( String, String )
