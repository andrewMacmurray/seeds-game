module Views.Level exposing (..)

import Html exposing (..)
import Model exposing (..)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.TopBar exposing (topBar)


level : Model -> Html Msg
level model =
    div [ handleStop model ]
        [ topBar model
        , board model
        ]
