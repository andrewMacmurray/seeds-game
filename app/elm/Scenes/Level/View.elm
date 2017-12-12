module Scenes.Level.View exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Scenes.Level.Types as Level
import Views.Backdrop exposing (backdrop)
import Views.Board.Layout exposing (board, handleStop)
import Views.Board.LineDrag exposing (handleLineDrag)
import Views.Board.TopBar exposing (topBar)


levelView : Level.Model -> Html Level.Msg
levelView model =
    div [ handleStop model ]
        [ topBar model
        , board model
        , handleLineDrag model
        , div [ class "w-100 h-100 fixed z-1 top-0", handleStop model ] [ backdrop ]
        ]
