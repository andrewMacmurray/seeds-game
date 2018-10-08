module Scenes.Hub.Types exposing (HubModel, HubMsg(..))

import Browser.Dom as Dom
import Data.InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (Progress)
import Data.Window as Window
import Shared


type alias HubModel =
    { shared : Shared.Data
    , infoWindow : InfoWindow Progress
    }


type HubMsg
    = ShowLevelInfo Progress
    | HideLevelInfo
    | SetInfoState (InfoWindow Progress)
    | ScrollHubToLevel Int
    | StartLevel Progress
    | DomNoOp (Result Dom.Error ())
