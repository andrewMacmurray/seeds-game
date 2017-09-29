module Scenes.Level.View exposing (..)

import Html exposing (div, Html)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)
import Model as Main
import Scenes.Level.Model as Level


levelView : Main.Model -> Html Level.Msg
levelView model =
    div [ handleStop model.levelModel ]
        [ topBar model.levelModel
        , board model
        , handleLineDrag model
        ]
