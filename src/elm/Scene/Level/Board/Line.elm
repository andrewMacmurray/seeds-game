module Scene.Level.Board.Line exposing
    ( ViewModel
    , view
    )

import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Bearing(..), State(..), Tile(..))
import Css.Style as Style exposing (Style, marginAuto, styles)
import Css.Transform exposing (..)
import Html exposing (Html, div, span)
import Scene.Level.Board.Tile.Style as Tile
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Window exposing (Window)



-- Model


type alias ViewModel =
    { window : Window
    , isSeedPodMove : Bool
    }



-- View


view : ViewModel -> Move -> Html msg
view model move =
    div
        [ styles
            [ Tile.widthHeightStyles model.window
            , Tile.coordStyles model.window <| Move.coord move
            ]
        , class "dib absolute touch-disabled"
        ]
        [ lineFromMove model move ]


lineFromMove : ViewModel -> Move -> Html msg
lineFromMove model move =
    let
        tileState =
            Move.tileState move
    in
    case tileState of
        Dragging tileType _ Left ->
            innerLine model tileType Left

        Dragging tileType _ Right ->
            innerLine model tileType Right

        Dragging tileType _ Up ->
            innerLine model tileType Up

        Dragging tileType _ Down ->
            innerLine model tileType Down

        _ ->
            span [] []


innerLine : ViewModel -> Tile -> Bearing -> Html msg
innerLine model tile bearing =
    let
        tileScale =
            Tile.scale model.window
    in
    svg
        [ width <| String.fromFloat <| 50 * tileScale
        , height <| String.fromFloat <| 9 * tileScale
        , Style.svgStyle
            [ marginAuto
            , lineTransforms model.window bearing
            ]
        , class "absolute bottom-0 right-0 left-0 top-0 z-0"
        ]
        [ line
            [ strokeWidth <| String.fromFloat <| 11 * tileScale
            , x1 "0"
            , y1 "0"
            , x2 <| String.fromFloat <| 50 * tileScale
            , y2 "0"
            , Style.svgStyle [ stroke model.isSeedPodMove tile ]
            ]
            []
        ]


stroke : Bool -> Tile -> Style
stroke isSeedPodMove tile =
    if isSeedPodMove then
        Style.stroke <| Tile.strokeColors SeedPod

    else
        Style.stroke <| Tile.strokeColors tile


lineTransforms : Window -> Bearing -> Style
lineTransforms window bearing =
    let
        xOffset =
            Tile.scale window * 25
    in
    case bearing of
        Left ->
            Style.transform [ translate -xOffset 1.5 ]

        Right ->
            Style.transform [ translate xOffset 1.5 ]

        Up ->
            Style.transform [ rotateZ 90, translate -xOffset 1.5 ]

        Down ->
            Style.transform [ rotateZ 90, translate xOffset 1.5 ]

        _ ->
            Style.none
