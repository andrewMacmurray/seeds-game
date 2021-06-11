module Scene.Level.Board.LineDrag exposing
    ( ViewModel
    , view
    )

import Board exposing (Board)
import Board.Move as Move
import Element
import Element.Palette as Palette
import Html exposing (Html)
import Pointer exposing (Pointer)
import Scene.Level.Board.Style as Board
import Scene.Level.Board.Tile.Scale as Scale
import Scene.Level.Board.Tile.Stroke as Stroke
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Utils.Html as Html
import Utils.Svg as Svg
import Window exposing (Window)


type alias ViewModel =
    { window : Window
    , boardSize : Board.Size
    , board : Board
    , isDragging : Bool
    , pointer : Pointer
    }


view : ViewModel -> Html msg
view model =
    if model.isDragging then
        lineDrag model

    else
        Html.none


lineDrag : ViewModel -> Html msg
lineDrag model =
    let
        window =
            model.window

        ( oY, oX ) =
            lastMoveOrigin model
    in
    Svg.window window
        [ class "fixed top-0 right-0 z-4 touch-disabled" ]
        [ Svg.line
            [ Svg.strokeWidth_ (Stroke.thickness window)
            , Svg.stroke_ (strokeColor model)
            , strokeLinecap "round"
            , x1 (String.fromFloat oX)
            , y1 (String.fromFloat oY)
            , x2 (String.fromInt model.pointer.x)
            , y2 (String.fromInt model.pointer.y)
            ]
            []
        ]


strokeColor : ViewModel -> Element.Color
strokeColor model =
    Board.activeMoveType model.board
        |> Maybe.map Stroke.darker
        |> Maybe.withDefault Palette.greyYellow


lastMoveOrigin : ViewModel -> ( Float, Float )
lastMoveOrigin model =
    let
        window =
            model.window

        lastMove =
            Board.lastMove model.board

        y1 =
            toFloat (Move.y lastMove)

        x1 =
            toFloat (Move.x lastMove)

        sY =
            toFloat (Scale.outerHeight window)

        sX =
            toFloat (Scale.outerWidth window)

        offsetY =
            Board.offsetTop (boardViewModel model) |> toFloat

        offsetX =
            (window.width - Board.width (boardViewModel model)) // 2 |> toFloat
    in
    ( ((y1 + 1) * sY) + offsetY - (sY / 2)
    , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
    )


boardViewModel : ViewModel -> Board.ViewModel
boardViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    }
