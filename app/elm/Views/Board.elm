module Views.Board exposing (..)

import Components.DebugTile exposing (debugTile)
import Data.Tiles exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tilePaddingMap)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown, onMouseEnter, onMouseUp)
import Model exposing (..)
import Styles.Board exposing (baseTileStyles, enteringStyles, fallingStyles, growingStyles, innerTileClasses, leavingStyles, tileCoordsStyles)
import Utils.Style exposing (classes, px, styles, translate)
import Utils.Window exposing (boardOffsetTop)


renderBoard : Model -> Html Msg
renderBoard model =
    boardLayout model
        [ div [] <| renderTiles model ]


renderTiles : Model -> List (Html Msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


boardLayout : Model -> List (Html Msg) -> Html Msg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ ( "width", px <| boardWidth model )
            , boardOffsetTop model
            ]
        ]


boardWidth : Model -> Float
boardWidth { tileSettings, boardSettings } =
    tileSettings.sizeX * toFloat (boardSettings.sizeX)


renderTile : Model -> Move -> Html Msg
renderTile model (( coord, tile ) as move) =
    div
        [ style <|
            styles
                [ baseTileStyles model
                , tileCoordsStyles model coord
                , leavingStyles model move
                ]
        , class "dib flex items-center justify-center absolute pointer"
        , hanldeMoveEvents model move
          -- id for debugging
        , id <| toString coord
        ]
        [ innerTile model move ]


handleStop : Model -> List (Attribute Msg)
handleStop model =
    if model.isDragging then
        [ onMouseUp StopMove ]
    else
        []


hanldeMoveEvents : Model -> Move -> Attribute Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter (CheckMove move)
    else
        onMouseDown (StartMove move)


innerTile : Model -> Move -> Html Msg
innerTile model (( coord, tile ) as move) =
    div
        [ class <| innerTileClasses model move
        , style <|
            styles
                [ [ tilePaddingMap tile ]
                , growingStyles model move
                , enteringStyles model move
                , fallingStyles model move
                ]
        ]
        [ debugTile coord ]
