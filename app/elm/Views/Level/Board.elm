module Views.Level.Board exposing (..)

import Data.Tile exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tileSizeMap)
import Dict
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (classes, px, styles, translate, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onMouseDown, onMouseEnter, onMouseUp)
import Model as MainModel exposing (Style)
import Scenes.Level.Model exposing (..)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (..)


board : MainModel.Model -> Html Msg
board model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model.levelModel
        ]


renderTiles : MainModel.Model -> List (Html Msg)
renderTiles model =
    model.levelModel.board
        |> Dict.toList
        |> List.map (renderTile model)


renderLines : Model -> List (Html Msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLineLayer model)


boardLayout : MainModel.Model -> List (Html Msg) -> Html Msg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ widthStyle <| boardWidth model.levelModel
            , boardMarginTop model
            ]
        ]


renderLineLayer : Model -> Move -> Html Msg
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


renderTile : MainModel.Model -> Move -> Html Msg
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


handleStop : Model -> Attribute Msg
handleStop model =
    if model.isDragging && model.moveShape /= Just Square then
        onMouseUp <| StopMove Line
    else
        emptyProperty


hanldeMoveEvents : Model -> Move -> Attribute Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDown <| StartMove move


tracer : Model -> Move -> Html Msg
tracer model move =
    let
        extraStyles =
            moveTracerStyles model move
    in
        makeInnerTile extraStyles model move


wall : Move -> Html Msg
wall move =
    div
        [ style <| wallStyles move
        , class centerBlock
        ]
        []


innerTile : Model -> Move -> Html Msg
innerTile model move =
    let
        extraStyles =
            draggingStyles model move
    in
        makeInnerTile extraStyles model move


makeInnerTile : List Style -> Model -> Move -> Html Msg
makeInnerTile extraStyles model (( _, tile ) as move) =
    div
        [ class <| baseTileClasses tile
        , style <|
            styles
                [ extraStyles
                , baseTileStyles model move
                ]
        ]
        []


baseTileStyles : Model -> Move -> List Style
baseTileStyles model (( _, tile ) as move) =
    styles
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , tileSizeMap tile
        , tileColorMap tile
        ]


baseTileClasses : Block -> String
baseTileClasses tile =
    classes
        [ "br-100"
        , centerBlock
        ]
