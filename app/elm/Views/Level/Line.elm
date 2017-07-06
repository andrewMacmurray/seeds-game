module Views.Level.Line exposing (..)

import Data.Tiles exposing (strokeColors)
import Formatting exposing ((<>), print, s)
import Helpers.Style exposing (rotateZ_, transform_, translate_)
import Html exposing (Html, span)
import Model exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


renderLine : Model -> Move -> Html Msg
renderLine model ( coord, tileState ) =
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


line_ : TileType -> MoveBearing -> Html Msg
line_ tileType bearing =
    svg
        [ width "50"
        , height "9"
        , Svg.Attributes.style <| String.join "; " [ transformMap bearing, "margin: auto" ]
        , class "absolute bottom-0 right-0 left-0 top-0 z-0"
        ]
        [ line
            [ strokeWidth "11"
            , x1 "0"
            , y1 "0"
            , x2 "50"
            , y2 "0"
            , class <| strokeColors tileType
            ]
            []
        ]


transformMap : MoveBearing -> String
transformMap bearing =
    case bearing of
        Left ->
            tTranslate -25 1.5

        Right ->
            tTranslate 25 1.5

        Up ->
            tRotateTranslate 90 -25 1.5

        Down ->
            tRotateTranslate 90 25 1.5

        _ ->
            ""


tRotateTranslate : number -> number -> number -> String
tRotateTranslate =
    transform_ (rotateZ_ <> translate_) |> print


tTranslate : number -> number -> String
tTranslate =
    transform_ translate_ |> print
