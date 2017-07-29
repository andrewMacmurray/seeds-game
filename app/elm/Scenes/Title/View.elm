module Scenes.Title.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model exposing (Msg(..), Scene(..))


title : model -> Html Msg
title model =
    div
        [ class "f3 relative z-5"
        , onClick <| SetScene Level
        ]
        [ text "title screen" ]
