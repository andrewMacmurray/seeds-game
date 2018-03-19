module Views.Level.LineDrag exposing (..)

import Config.Scale as ScaleConfig
import Data.Board.Moves exposing (currentMoveTileType, lastMove)
import Data.Board.Move.Square exposing (hasSquareTile)
import Helpers.Style exposing (..)
import Html exposing (Html, span)
import Scenes.Level.Types as Level exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Level.Styles exposing (..)


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

        strokeColor =
            currentMoveTileType model.board
                |> Maybe.map strokeColors
                |> Maybe.withDefault ""

        tileScale =
            ScaleConfig.tileScaleFactor window
    in
        svg
            [ width <| px window.width
            , height <| px window.height
            , viewBox vb
            , class "fixed top-0 right-0 z-2 touch-disabled"
            ]
            [ line
                [ svgStyle "stroke" strokeColor
                , strokeWidth <| toString <| 6 * tileScale
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
            (window.width - (boardWidth model)) // 2 |> toFloat
    in
        ( ((y1 + 1) * sY) + offsetY - (sY / 2)
        , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
        )
