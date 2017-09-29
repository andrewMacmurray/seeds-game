module Scenes.Title exposing (..)

import Data.Color exposing (darkYellow, gold, lightOrange, orange, white)
import Helpers.Style exposing (backgroundColor, color, marginTop, px, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model as Main exposing (..)
import Scenes.Hub.Model exposing (..)
import Views.Title.Seeds exposing (seeds)


titleView : Main.Model -> Html Main.Msg
titleView model =
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
            , onClick <| HubMsg GoToHub
            , style
                [ ( "border", "none" )
                , marginTop 15
                , color white
                , backgroundColor lightOrange
                ]
            ]
            [ text "PLAY" ]
        ]


percentWindowHeight : Float -> HasWindow a -> Float
percentWindowHeight percent model =
    toFloat model.window.height / 100 * percent
