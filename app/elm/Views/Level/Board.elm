module Views.Level.Board exposing (..)

import Data.Tile exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tileSizeMap)
import Dict
import Helpers.Html exposing (emptyProperty)
import Helpers.Style exposing (classes, px, styles, translate, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onMouseDown, onMouseEnter, onMouseUp)
import Json.Decode as Json
import Model exposing (..)
import Mouse exposing (position)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (..)


board : Model -> Html Msg
board model =
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
            [ widthStyle <| boardWidth model
            , boardMarginTop model
            ]
        ]


renderTile : Model -> Move -> Html Msg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ style <|
            styles
                [ tileWidthHeightStyles model
                , tileCoordsStyles model coord
                , leavingStyles model move
                ]
        , class "dib absolute pointer"
        , hanldeMoveEvents model move
        ]
        [ renderLine model move
        , innerTile model move
        , tracer model move
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
        onMouseDownStartMove move


onMouseDownStartMove : Move -> Attribute Msg
onMouseDownStartMove move =
    on "mousedown" (position |> Json.map (StartMove move))


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
        ]


baseTileClasses : Block -> String
baseTileClasses tile =
    classes
        [ "br-100"
        , centerBlock
        , tileColorMap tile
        ]
