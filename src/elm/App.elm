module App exposing (main)

import Browser
import State exposing (init, subscriptions, update)
import Types exposing (Flags, Model, Msg)
import View exposing (view)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
