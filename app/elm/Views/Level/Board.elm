module Views.Level.Board exposing (..)

import Data.Level.Board.Tile exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tileSizeMap)
import Dict
import Helpers.Html exposing (emptyProperty, onMouseDownPreventDefault)
import Helpers.Style exposing (classes, px, styles, translate, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter, onMouseUp)
import Model exposing (Style, Model)
import Data.Level.Types exposing (..)
import Scenes.Level.Model exposing (..)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (..)


board : Model -> Html LevelMsg
board model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model.levelModel
        ]


renderTiles : Model -> List (Html LevelMsg)
renderTiles model =
    model.levelModel.board
        |> Dict.toList
        |> List.map (renderTile model)


renderLines : LevelModel -> List (Html LevelMsg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLineLayer model)


boardLayout : Model -> List (Html LevelMsg) -> Html LevelMsg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ widthStyle <| boardWidth model.levelModel
            , boardMarginTop model
            ]
        ]


renderLineLayer : LevelModel -> Move -> Html LevelMsg
renderLineLayer model (( ( y, x ) as coord, tile ) as move) =
    div
        [ style <|
            styles
                [ tileWidthHeightStyles model
                , tileCoordsStyles model coord
                ]
        , class "dib absolute touch-disabled"
        ]
        [ renderLine model move
        ]


renderTile : Model -> Move -> Html LevelMsg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ style <|
            styles
                [ tileWidthHeightStyles model.levelModel
                , tileCoordsStyles model.levelModel coord
                , leavingStyles model move
                ]
        , class "dib absolute pointer"
        , hanldeMoveEvents model.levelModel move
        ]
        [ innerTile model.levelModel move
        , tracer model.levelModel move
        , wall move
        ]


handleStop : LevelModel -> Attribute LevelMsg
handleStop model =
    if model.isDragging && model.moveShape /= Just Square then
        onMouseUp <| StopMove Line
    else
        emptyProperty


hanldeMoveEvents : LevelModel -> Move -> Attribute LevelMsg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDownPreventDefault <| StartMove move


tracer : LevelModel -> Move -> Html LevelMsg
tracer model move =
    let
        extraStyles =
            moveTracerStyles model move
    in
        makeInnerTile extraStyles model move


wall : Move -> Html LevelMsg
wall move =
    div
        [ style <| wallStyles move
        , class centerBlock
        ]
        []


innerTile : LevelModel -> Move -> Html LevelMsg
innerTile model move =
    let
        extraStyles =
            draggingStyles model move
    in
        makeInnerTile extraStyles model move


makeInnerTile : List Style -> LevelModel -> Move -> Html LevelMsg
makeInnerTile extraStyles model (( _, tile ) as move) =
    div
        [ class <| baseTileClasses tile
        , style <|
            styles
                [ extraStyles
                , baseTileStyles model move
                , [ ( "will-change", "transform, opacity" ) ]
                ]
        ]
        []


baseTileStyles : LevelModel -> Move -> List Style
baseTileStyles model (( _, tile ) as move) =
    styles
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , tileSizeMap tile
        , tileColorMap model.seedType tile
        ]


baseTileClasses : Block -> String
baseTileClasses tile =
    classes
        [ "br-100"
        , centerBlock
        ]
