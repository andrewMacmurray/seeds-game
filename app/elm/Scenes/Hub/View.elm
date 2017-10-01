module Scenes.Hub.View exposing (..)

import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Hub.Types as Hub exposing (..)
import Data.Color exposing (..)
import Views.Hub.Info exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Views.TitleSeeds exposing (seeds)
import Window


hubView : Hub.Model -> Html Hub.Msg
hubView model =
    div
        [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
        , id "hub"
        , style [ heightStyle model.window.height ]
        , handleHideInfo model
        ]
        (hubContent model)


hubContent : Hub.Model -> List (Html Hub.Msg)
hubContent model =
    [ info model ] ++ renderWorlds model


titleView : Hub.Model -> Html Hub.Msg
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
            , onClick GoToHub
            , style
                [ ( "border", "none" )
                , marginTop 15
                , color white
                , backgroundColor lightOrange
                ]
            ]
            [ text "PLAY" ]
        ]


percentWindowHeight : Float -> { a | window : Window.Size } -> Float
percentWindowHeight percent model =
    toFloat model.window.height / 100 * percent
