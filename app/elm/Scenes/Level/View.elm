module Scenes.Level.View exposing (..)

import Html exposing (div, Html)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)
import Model exposing (Model)
import Scenes.Level.Model exposing (LevelMsg)


levelView : Model -> Html LevelMsg
levelView model =
    div [ handleStop model.levelModel ]
        [ topBar model.levelModel
        , board model
        , handleLineDrag model
        ]
