module App exposing (main)

import Html
import Scenes.Hub.State as Hub
import Scenes.Hub.Types exposing (Model, Msg)
import Types exposing (Flags)
import View exposing (view)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = Hub.init
        , update = Hub.update
        , view = view
        , subscriptions = Hub.subscriptions
        }
