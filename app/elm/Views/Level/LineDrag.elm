module Views.Level.LineDrag exposing (..)

import Data.Level.Move.Square exposing (hasSquareTile)
import Data.Level.Move.Utils exposing (currentMoves, lastMove, currentMoveTileType)
import Data.Level.Board.Tile exposing (strokeColors)
import Helpers.Style exposing (px)
import Html exposing (Html, span)
import Scenes.Level.Types as Level exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (boardOffsetTop, boardWidth)


handleLineDrag : Level.Model -> Html Level.Msg
handleLineDrag model =
    if model.isDragging && hasSquareTile model.board |> not then
        lineDrag model
    else
        span [] []


lineDrag : Level.Model -> Html Level.Msg
lineDrag ({ window } as model) =
    let
        vb =
            "0 0 " ++ toString window.width ++ " " ++ toString window.height

        ( oY, oX ) =
            lastMoveOrigin model

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
                [ Svg.Attributes.style colorClass
                , strokeWidth "6"
                , strokeLinecap "round"
                , x1 <| toString oX
                , y1 <| toString oY
                , x2 <| toString model.mouse.x
                , y2 <| toString model.mouse.y
                ]
                []
            ]


lastMoveOrigin : Level.Model -> ( Float, Float )
lastMoveOrigin ({ window } as model) =
    let
        tileSize =
            model.tileSize

        ( ( y, x ), _ ) =
            lastMove model.board

        y1 =
            toFloat y

        x1 =
            toFloat x

        sY =
            tileSize.y

        sX =
            tileSize.x

        offsetY =
            boardOffsetTop model |> toFloat

        offsetX =
            (window.width - (boardWidth model)) // 2 |> toFloat
    in
        ( ((y1 + 1) * sY) + offsetY - (sY / 2)
        , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
        )
