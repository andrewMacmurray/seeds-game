module App exposing (main)

import Html
import Types exposing (Flags, Model, Msg)
import View exposing (view)
import State exposing (init, update, subscriptions)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
