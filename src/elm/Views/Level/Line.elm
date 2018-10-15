module Views.Level.Line exposing (renderLine)

import Config.Scale exposing (tileScaleFactor)
import Data.Board.Block exposing (getTileState)
import Data.Board.Types exposing (..)
import Shared exposing (Window)
import Css.Style as Style exposing (Style, marginAuto, svgStyle, svgStyles)
import Css.Transform as Transform exposing (..)
import Html exposing (Html, span)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (strokeColors)


renderLine : Window -> Move -> Html msg
renderLine window ( coord, block ) =
    let
        tileState =
            getTileState block
    in
    case tileState of
        Dragging tileType _ Left _ ->
            line_ window tileType Left

        Dragging tileType _ Right _ ->
            line_ window tileType Right

        Dragging tileType _ Up _ ->
            line_ window tileType Up

        Dragging tileType _ Down _ ->
            line_ window tileType Down

        _ ->
            span [] []


line_ : Window -> TileType -> MoveBearing -> Html msg
line_ window tileType bearing =
    let
        tileScale =
            tileScaleFactor window
    in
    svg
        [ width <| String.fromFloat <| 50 * tileScale
        , height <| String.fromFloat <| 9 * tileScale
        , svgStyles
            [ marginAuto
            , lineTransforms window bearing
            ]
        , class "absolute bottom-0 right-0 left-0 top-0 z-0"
        ]
        [ line
            [ strokeWidth <| String.fromFloat <| 11 * tileScale
            , x1 "0"
            , y1 "0"
            , x2 <| String.fromFloat <| 50 * tileScale
            , y2 "0"
            , svgStyle <| Style.stroke <| strokeColors tileType
            ]
            []
        ]


lineTransforms : Window -> MoveBearing -> Style
lineTransforms window bearing =
    let
        xOffset =
            tileScaleFactor window * 25
    in
    case bearing of
        Left ->
            Style.transform [ translate -xOffset 1.5 ]

        Right ->
            Style.transform [ translate xOffset 1.5 ]

        Up ->
            Style.transform [ rotateZ 90, translate -xOffset 1.5 ]

        Down ->
            Style.transform [ rotateZ 90, translate xOffset 1.5 ]

        _ ->
            Style.empty
