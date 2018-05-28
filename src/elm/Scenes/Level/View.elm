module Scenes.Level.View exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Views.Backdrop exposing (backdrop)
import Views.Level.Layout exposing (board, handleCheck, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.Result exposing (infoWindow)
import Views.Level.TopBar exposing (topBar)


levelView : LevelModel -> Html LevelMsg
levelView model =
    div [ handleStop model, handleCheck model, class <| disableIfComplete model ]
        [ topBar model
        , infoWindow model
        , board model
        , handleLineDrag model
        , div [ class "w-100 h-100 fixed z-1 top-0" ] [ backdrop ]
        ]


disableIfComplete : LevelModel -> String
disableIfComplete model =
    if not <| model.levelStatus == InProgress then
        "touch-disabled"
    else
        ""
