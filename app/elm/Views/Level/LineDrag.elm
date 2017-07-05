module Views.Level.LineDrag exposing (..)

import Data.Moves.Type exposing (currentMoveTileType)
import Data.Moves.Utils exposing (currentMoves, lastMove)
import Data.Tiles exposing (strokeColors)
import Helpers.Style exposing (px)
import Html exposing (Html, span)
import Model exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (boardOffsetTop, boardWidth)


handleLineDrag : Model -> Html Msg
handleLineDrag model =
    if model.isDragging && model.moveShape == Just Line then
        lineDrag model
    else
        span [] []


lineDrag : Model -> Html Msg
lineDrag model =
    let
        w =
            model.window.width

        h =
            model.window.height

        vb =
            "0 0 " ++ toString w ++ " " ++ toString h

        ( oY, oX ) =
            getOrigins model

        colorClass =
            currentMoveTileType model.board
                |> Maybe.map strokeColors
                |> Maybe.withDefault ""
    in
        svg
            [ width <| px w
            , height <| px h
            , viewBox vb
            , class "fixed top-0 right-0 z-1 touch-disabled"
            ]
            [ line
                [ class colorClass
                , strokeWidth "5"
                , x1 <| toString oX
                , y1 <| toString oY
                , x2 <| toString model.mouse.x
                , y2 <| toString model.mouse.y
                ]
                []
            ]


getOrigins model =
    let
        ( ( y, x ), _ ) =
            lastMove model.board

        y1 =
            toFloat y

        x1 =
            toFloat x

        offsetY =
            boardOffsetTop model |> toFloat

        offsetX =
            (model.window.width - (boardWidth model)) // 2 |> toFloat
    in
        ( ((y1 + 1) * 51) + offsetY - (51 / 2)
        , ((x1 + 1) * 55) + offsetX - (55 / 2) + 1
        )
