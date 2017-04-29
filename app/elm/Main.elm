module Main exposing (..)

import Update exposing (..)
import Model exposing (..)
import View exposing (..)
import Html exposing (..)


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
