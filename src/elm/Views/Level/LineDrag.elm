module Views.Level.LineDrag exposing (LineViewModel, handleLineDrag)

import Css.Style as Style exposing (svgStyle)
import Css.Unit exposing (px)
import Data.Board.Move.Square exposing (hasSquareTile)
import Data.Board.Moves exposing (currentMoveTileType, lastMove)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (Board, BoardDimensions)
import Data.Pointer exposing (Pointer)
import Data.Window exposing (Window)
import Html exposing (Html, span)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (..)


type alias LineViewModel =
    { window : Window
    , boardDimensions : BoardDimensions
    , board : Board
    , isDragging : Bool
    , pointer : Pointer
    }


handleLineDrag : LineViewModel -> Html msg
handleLineDrag model =
    if model.isDragging && hasSquareTile model.board |> not then
        lineDrag model

    else
        span [] []


lineDrag : LineViewModel -> Html msg
lineDrag model =
    let
        window =
            model.window

        vb =
            "0 0 " ++ String.fromInt window.width ++ " " ++ String.fromInt window.height

        ( oY, oX ) =
            lastMoveOrigin model

        strokeColor =
            currentMoveTileType model.board
                |> Maybe.map strokeColors
                |> Maybe.withDefault ""

        tileScale =
            Tile.scale window
    in
    svg
        [ width <| px <| toFloat window.width
        , height <| px <| toFloat window.height
        , viewBox vb
        , class "fixed top-0 right-0 z-2 touch-disabled"
        ]
        [ line
            [ svgStyle <| Style.stroke strokeColor
            , strokeWidth <| String.fromFloat <| 6 * tileScale
            , strokeLinecap "round"
            , x1 <| String.fromFloat oX
            , y1 <| String.fromFloat oY
            , x2 <| String.fromInt model.pointer.x
            , y2 <| String.fromInt model.pointer.y
            ]
            []
        ]


lastMoveOrigin : LineViewModel -> ( Float, Float )
lastMoveOrigin model =
    let
        window =
            model.window

        tileScale =
            Tile.scale window

        ( ( y, x ), _ ) =
            lastMove model.board

        y1 =
            toFloat y

        x1 =
            toFloat x

        sY =
            Tile.baseSizeY * tileScale

        sX =
            Tile.baseSizeX * tileScale

        vm =
            ( model.window, model.boardDimensions )

        offsetY =
            boardOffsetTop vm |> toFloat

        offsetX =
            (window.width - boardWidth vm) // 2 |> toFloat
    in
    ( ((y1 + 1) * sY) + offsetY - (sY / 2)
    , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
    )
