module Scenes.Hub.Types exposing (..)

import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (Progress)
import Dom
import Time exposing (Time)
import Window


type alias HubModel mainModel =
    { mainModel
        | hubInfoWindow : InfoWindow Progress
        , window : Window.Size
        , timeTillNextLife : Time
        , progress : Progress
    }


type HubMsg
    = ShowLevelInfo Progress
    | HideLevelInfo
    | SetInfoState (InfoWindow Progress)
    | ScrollHubToLevel Int
    | ReceiveHubLevelOffset Float
    | DomNoOp (Result Dom.Error ())
