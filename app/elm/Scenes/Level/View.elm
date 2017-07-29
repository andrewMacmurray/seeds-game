module Scenes.Level.View exposing (..)

import Html exposing (..)
import Scenes.Level.Model exposing (..)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)


level : Model -> Html Msg
level model =
    div [ handleStop model ]
        [ topBar model
        , board model
        , handleLineDrag model
        ]
