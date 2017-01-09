module Main exposing (..)

import Html exposing (..)
import Update exposing (..)
import View exposing (..)
import Types exposing (..)


main : Program Never Model Msg
main =
    program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
