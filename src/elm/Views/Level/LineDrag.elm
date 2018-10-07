module Views.Level.LineDrag exposing (handleLineDrag)

import Config.Scale as ScaleConfig
import Data.Board.Move.Square exposing (hasSquareTile)
import Data.Board.Moves exposing (currentMoveTileType, lastMove)
import Css.Style as Style exposing (svgStyle)
import Css.Unit exposing (px)
import Html exposing (Html, span)
import Scenes.Level.Types as Level exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (..)


handleLineDrag : LevelModel -> Html msg
handleLineDrag model =
    if model.isDragging && hasSquareTile model.board |> not then
        lineDrag model

    else
        span [] []


lineDrag : LevelModel -> Html msg
lineDrag ({ window } as model) =
    let
        vb =
            "0 0 " ++ String.fromInt window.width ++ " " ++ String.fromInt window.height

        ( oY, oX ) =
            lastMoveOrigin model

        strokeColor =
            currentMoveTileType model.board
                |> Maybe.map strokeColors
                |> Maybe.withDefault ""

        tileScale =
            ScaleConfig.tileScaleFactor window
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
            , x2 <| String.fromInt model.pointerPosition.x
            , y2 <| String.fromInt model.pointerPosition.y
            ]
            []
        ]


lastMoveOrigin : LevelModel -> ( Float, Float )
lastMoveOrigin ({ window } as model) =
    let
        tileScale =
            ScaleConfig.tileScaleFactor window

        ( ( y, x ), _ ) =
            lastMove model.board

        y1 =
            toFloat y

        x1 =
            toFloat x

        sY =
            ScaleConfig.baseTileSizeY * tileScale

        sX =
            ScaleConfig.baseTileSizeX * tileScale

        offsetY =
            boardOffsetTop model |> toFloat

        offsetX =
            (window.width - boardWidth model) // 2 |> toFloat
    in
    ( ((y1 + 1) * sY) + offsetY - (sY / 2)
    , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
    )
