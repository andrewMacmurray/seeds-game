module Scenes.Level.View exposing (..)

import Html exposing (Html, div)
import Scenes.Level.Model as Level
import Views.Backdrop exposing (backdrop)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)


levelView : Level.Model -> Html Level.Msg
levelView model =
    div [ handleStop model ]
        [ topBar model
        , board model
        , handleLineDrag model
        , div [ handleStop model ] [ backdrop ]
        ]
