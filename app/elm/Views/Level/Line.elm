module Views.Level.Line exposing (..)

import Data.Tiles exposing (strokeColors)
import Html exposing (Html, span)
import Model exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


renderLine : Model -> Move -> Html Msg
renderLine model ( coord, tileState ) =
    case tileState of
        Dragging tileType _ Left _ ->
            testLine tileType Left

        Dragging tileType _ Right _ ->
            testLine tileType Right

        Dragging tileType _ Up _ ->
            testLine tileType Up

        Dragging tileType _ Down _ ->
            testLine tileType Down

        _ ->
            span [] []


testLine tileType bearing =
    svg
        [ width "50"
        , height "9"
        , Svg.Attributes.style <| transformMap bearing
        , class "relative z-0"
        ]
        [ line
            [ strokeWidth "9"
            , x1 "0"
            , y1 "0"
            , x2 "50"
            , y2 "0"
            , class <| strokeColors tileType
            ]
            []
        ]


transformMap bearing =
    case bearing of
        Left ->
            "transform: translateX(-25px) translateY(1.5px)"

        Right ->
            "transform: translateX(25px) translateY(1.5px)"

        Up ->
            "transform: rotateZ(90deg) translateX(-25px) translateY(1.5px)"

        Down ->
            "transform: rotateZ(90deg) translateX(25px) translateY(1.5px)"

        _ ->
            ""
