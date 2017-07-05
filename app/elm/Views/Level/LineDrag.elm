module Views.Level.LineDrag exposing (..)

import Data.Moves.Square exposing (hasSquareTile)
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
    if model.isDragging && hasSquareTile model.board |> not then
        lineDrag model
    else
        span [] []


lineDrag : Model -> Html Msg
lineDrag ({ window } as model) =
    let
        vb =
            "0 0 " ++ toString window.width ++ " " ++ toString window.height

        ( oY, oX ) =
            getOrigins model

        colorClass =
            currentMoveTileType model.board
                |> Maybe.map strokeColors
                |> Maybe.withDefault ""
    in
        svg
            [ width <| px window.width
            , height <| px window.height
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


getOrigins : Model -> ( Float, Float )
getOrigins ({ window, tileSettings } as model) =
    let
        ( ( y, x ), _ ) =
            lastMove model.board

        y1 =
            toFloat y

        x1 =
            toFloat x

        sY =
            tileSettings.sizeY

        sX =
            tileSettings.sizeX

        offsetY =
            boardOffsetTop model |> toFloat

        offsetX =
            (window.width - (boardWidth model)) // 2 |> toFloat
    in
        ( ((y1 + 1) * sY) + offsetY - (sY / 2)
        , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
        )
