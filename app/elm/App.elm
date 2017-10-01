module App exposing (main)

import Scenes.Hub.Types exposing (Model, Msg)
import Scenes.Hub.State as Hub
import View exposing (view)
import Html exposing (program)


main : Program Never Model Msg
main =
    program
        { init = Hub.init
        , update = Hub.update
        , view = view
        , subscriptions = Hub.subscriptions
        }
