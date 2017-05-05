module Views.Board exposing (..)

import Data.Moves.Check exposing (isInCurrentMove)
import Data.Tiles exposing (isLeaving, leavingOrder, tileColorMap, tilePaddingMap)
import Dict
import Helpers.Style exposing (classes, px, styles, translate)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown, onMouseEnter, onMouseUp)
import Model exposing (..)


renderBoard : Model -> Html Msg
renderBoard model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)
        |> renderContainer model


renderContainer : Model -> List (Html Msg) -> Html Msg
renderContainer model =
    div
        [ class "relative z-3 center mt5 flex flex-wrap"
        , style [ ( "width", px <| boardWidth model ) ]
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
                , leavingStyles move
                ]
        , class "dib flex items-center justify-center absolute pointer"
        , hanldeMoveEvents model move
        ]
        [ innerTile model move ]


tileCoordsStyles : Model -> Coord -> List ( String, String )
tileCoordsStyles model coord =
    let
        ( y, x ) =
            tilePosition model coord
    in
        [ ( "transform", translate x y ) ]


tilePosition : Model -> Coord -> ( Float, Float )
tilePosition model ( y, x ) =
    ( (toFloat y) * model.tileSettings.sizeY
    , (toFloat x) * model.tileSettings.sizeX
    )


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
    let
        innerTileClasses =
            classes
                [ "br-100 absolute"
                , tileColorMap tile
                , draggingClasses model move
                ]
    in
        div
            [ class innerTileClasses
            , style [ ( "padding", tilePaddingMap tile ) ]
            ]
            []


leavingStyles : Move -> List ( String, String )
leavingStyles ( ( y, x ), tile ) =
    if isLeaving tile then
        [ ( "transform", translate x ((-8 + y) * 10) )
        , ( "transition", "0.8s ease" )
        , ( "transition-delay", (toString ((leavingOrder tile) * 80)) ++ "ms" )
        ]
    else
        []


draggingClasses : Model -> Move -> String
draggingClasses model coord =
    if isInCurrentMove coord model.currentMove then
        "scale-half t3 ease"
    else
        "scale-full"


baseTileStyles : Model -> List ( String, String )
baseTileStyles { tileSettings } =
    [ ( "width", px tileSettings.sizeX )
    , ( "height", px tileSettings.sizeY )
    ]
