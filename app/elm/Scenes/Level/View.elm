module Scenes.Level.View exposing (..)

import Html exposing (..)
import Scenes.Level.Model exposing (..)
import Model as MainModel
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)


level : MainModel.Model -> Html Msg
level model =
    div [ handleStop model.levelModel ]
        [ topBar model.levelModel
        , board model
        , handleLineDrag model
        ]
