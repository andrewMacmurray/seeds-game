module Views.Level.Line exposing (line_, renderLine, transformMap)

import Config.Scale exposing (tileScaleFactor)
import Data.Board.Block exposing (getTileState)
import Data.Board.Types exposing (..)
import Data.Window as Window
import Helpers.Css.Style exposing (..)
import Helpers.Css.Transform exposing (..)
import Html exposing (Html, span)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (strokeColors)


renderLine : Window.Size -> Move -> Html msg
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


line_ : Window.Size -> TileType -> MoveBearing -> Html msg
line_ window tileType bearing =
    let
        tileScale =
            tileScaleFactor window
    in
    svg
        [ width <| Debug.toString <| 50 * tileScale
        , height <| Debug.toString <| 9 * tileScale
        , svgStyles
            [ transformMap window bearing
            , "margin: auto"
            ]
        , class "absolute bottom-0 right-0 left-0 top-0 z-0"
        ]
        [ line
            [ strokeWidth <| Debug.toString <| 11 * tileScale
            , x1 "0"
            , y1 "0"
            , x2 <| Debug.toString <| 50 * tileScale
            , y2 "0"
            , svgStyle "stroke" <| strokeColors tileType
            ]
            []
        ]


transformMap : Window.Size -> MoveBearing -> String
transformMap window bearing =
    let
        xOffset =
            tileScaleFactor window * 25
    in
    case bearing of
        Left ->
            transformSvg [ translate -xOffset 1.5 ]

        Right ->
            transformSvg [ translate xOffset 1.5 ]

        Up ->
            transformSvg [ rotateZ 90, translate -xOffset 1.5 ]

        Down ->
            transformSvg [ rotateZ 90, translate xOffset 1.5 ]

        _ ->
            ""
