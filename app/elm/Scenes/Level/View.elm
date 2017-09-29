module Scenes.Level.View exposing (..)

import Html exposing (div, Html)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)
import Scenes.Level.Model as Level


levelView : Level.Model -> Html Level.Msg
levelView model =
    div [ handleStop model ]
        [ topBar model
        , board model
        , handleLineDrag model
        ]
