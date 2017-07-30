module Scenes.Title.View exposing (..)

import Data.Color exposing (darkYellow, gold, lightOrange, orange, white)
import Helpers.Style exposing (backgroundColor, color, marginTop, px, widthStyle)
import Helpers.Window exposing (percentWindowHeight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model exposing (..)
import Views.Title.Seeds exposing (seeds)


title : Model -> Html Msg
title model =
    div [ class "relative z-5 tc" ]
        [ div
            [ style [ marginTop <| percentWindowHeight 17 model ] ]
            [ seeds ]
        , p
            [ class "f3 tracked-mega"
            , style [ color darkYellow, marginTop 45 ]
            ]
            [ text "seeds" ]
        , button
            [ class "outline-0 br4 pv2 ph3 f5 pointer sans-serif tracked-mega"
            , onClick StartLevel
            , style
                [ ( "border", "none" )
                , marginTop 15
                , color white
                , backgroundColor lightOrange
                ]
            ]
            [ text "PLAY" ]
        ]
