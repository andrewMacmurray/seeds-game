module Main exposing (..)

import Model exposing (..)
import Update exposing (..)
import View exposing (..)
import Html exposing (program)


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
