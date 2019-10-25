module Scenes.Level.LineDrag exposing (LineViewModel, handleLineDrag)

import Board exposing (Board)
import Board.Move as Move
import Board.Tile as Tile
import Css.Color as Color
import Css.Style as Style
import Html exposing (Html, span)
import Pointer exposing (Pointer)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (height_, width_, windowViewBox_)
import Views.Board.Tile.Styles exposing (..)
import Window exposing (Window)


type alias LineViewModel =
    { window : Window
    , boardDimensions : Board.Size
    , board : Board
    , isDragging : Bool
    , pointer : Pointer
    }


handleLineDrag : LineViewModel -> Html msg
handleLineDrag model =
    if model.isDragging then
        lineDrag model

    else
        span [] []


lineDrag : LineViewModel -> Html msg
lineDrag model =
    let
        window =
            model.window

        ( oY, oX ) =
            lastMoveOrigin model

        strokeColor =
            Board.currentMoveType model.board
                |> Maybe.map strokeColors
                |> Maybe.withDefault Color.greyYellow

        tileScale =
            Tile.scale window
    in
    svg
        [ width_ <| toFloat window.width
        , height_ <| toFloat window.height
        , windowViewBox_ window
        , class "fixed top-0 right-0 z-4 touch-disabled"
        ]
        [ line
            [ Style.svgStyle [ Style.stroke strokeColor ]
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

        lastMove =
            Board.lastMove model.board

        y1 =
            toFloat <| Move.y lastMove

        x1 =
            toFloat <| Move.x lastMove

        sY =
            Tile.baseSizeY * tileScale

        sX =
            Tile.baseSizeX * tileScale

        tileViewModel =
            ( model.window, model.boardDimensions )

        offsetY =
            boardOffsetTop tileViewModel |> toFloat

        offsetX =
            (window.width - boardWidth tileViewModel) // 2 |> toFloat
    in
    ( ((y1 + 1) * sY) + offsetY - (sY / 2)
    , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
    )
