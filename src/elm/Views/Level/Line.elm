module Views.Level.Line exposing (..)

import Data.Level.Board.Block exposing (getTileState)
import Formatting exposing ((<>), print, s)
import Config.Scale exposing (tileScaleFactor)
import Helpers.Style exposing (..)
import Html exposing (Html, span)
import Scenes.Level.Types as Level exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (strokeColors)
import Window


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
            [ width <| toString <| 50 * tileScale
            , height <| toString <| 9 * tileScale
            , svgStyles
                [ transformMap window bearing
                , "margin: auto"
                ]
            , class "absolute bottom-0 right-0 left-0 top-0 z-0"
            ]
            [ line
                [ strokeWidth <| toString <| 11 * tileScale
                , x1 "0"
                , y1 "0"
                , x2 <| toString <| 50 * tileScale
                , y2 "0"
                , svgStyle "stroke" <| strokeColors tileType
                ]
                []
            ]


transformMap : Window.Size -> MoveBearing -> String
transformMap window bearing =
    let
        tileScale =
            tileScaleFactor window
    in
        case bearing of
            Left ->
                translate (-25 * tileScale) 1.5

            Right ->
                translate (25 * tileScale) 1.5

            Up ->
                rotateTranslate 90 (-25 * tileScale) 1.5

            Down ->
                rotateTranslate 90 (25 * tileScale) 1.5

            _ ->
                ""


rotateTranslate : number -> number -> number -> String
rotateTranslate =
    transform_ (rotateZ_ <> translate_) |> print


translate : number -> number -> String
translate =
    transform_ translate_ |> print
