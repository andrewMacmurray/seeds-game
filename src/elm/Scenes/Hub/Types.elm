module Scenes.Hub.Types exposing (HubModel, HubMsg(..))

import Browser.Dom as Dom
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (Progress)
import Data.Window as Window


type alias HubModel mainModel =
    { mainModel
        | hubInfoWindow : InfoWindow Progress
        , window : Window.Size
        , timeTillNextLife : Float
        , progress : Progress
    }


type HubMsg
    = ShowLevelInfo Progress
    | HideLevelInfo
    | SetInfoState (InfoWindow Progress)
    | ScrollHubToLevel Int
    | ReceiveHubLevelOffset Float
    | DomNoOp (Result Dom.Error ())
