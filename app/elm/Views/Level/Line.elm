module Views.Level.Line exposing (..)

import Data.Level.Board.Block exposing (getTileState)
import Data.Level.Board.Tile exposing (strokeColors)
import Formatting exposing ((<>), print, s)
import Helpers.Style exposing (rotateZ_, svgStyles, transform_, translate_)
import Html exposing (Html, span)
import Scenes.Level.Types exposing (..)
import Scenes.Level.Types as Level
import Svg exposing (..)
import Svg.Attributes exposing (..)


renderLine : Level.Model -> Move -> Html Level.Msg
renderLine model ( coord, block ) =
    let
        tileState =
            getTileState block
    in
        case tileState of
            Dragging tileType _ Left _ ->
                line_ tileType Left

            Dragging tileType _ Right _ ->
                line_ tileType Right

            Dragging tileType _ Up _ ->
                line_ tileType Up

            Dragging tileType _ Down _ ->
                line_ tileType Down

            _ ->
                span [] []


line_ : TileType -> MoveBearing -> Html Level.Msg
line_ tileType bearing =
    svg
        [ width "50"
        , height "9"
        , Svg.Attributes.style <|
            svgStyles
                [ transformMap bearing
                , "margin: auto"
                ]
        , class "absolute bottom-0 right-0 left-0 top-0 z-0"
        ]
        [ line
            [ strokeWidth "11"
            , x1 "0"
            , y1 "0"
            , x2 "50"
            , y2 "0"
            , Svg.Attributes.style <| strokeColors tileType
            ]
            []
        ]


transformMap : MoveBearing -> String
transformMap bearing =
    case bearing of
        Left ->
            translate -25 1.5

        Right ->
            translate 25 1.5

        Up ->
            rotateTranslate 90 -25 1.5

        Down ->
            rotateTranslate 90 25 1.5

        _ ->
            ""


rotateTranslate : number -> number -> number -> String
rotateTranslate =
    transform_ (rotateZ_ <> translate_) |> print


translate : number -> number -> String
translate =
    transform_ translate_ |> print
