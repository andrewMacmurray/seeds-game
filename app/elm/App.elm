module Main exposing (..)

import Scenes.Hub.Model exposing (Model, Msg)
import Scenes.Hub.Update exposing (update, subscriptions, init)
import Scenes.Router exposing (view)
import Html exposing (program)


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
