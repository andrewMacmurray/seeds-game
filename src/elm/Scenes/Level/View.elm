module Scenes.Level.View exposing (disableIfComplete, levelView)

import Css.Style exposing (..)
import Data.Board.Types exposing (Move)
import Data.InfoWindow exposing (isHidden, val)
import Dict
import Helpers.Html exposing (emptyProperty, onPointerDownPosition, onPointerMovePosition, onPointerUp)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (..)
import Views.Backdrop exposing (backdrop)
import Views.InfoWindow exposing (infoContainer)
import Views.Level.Line exposing (renderLine)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.Styles exposing (boardMarginTop, boardWidth, leavingStyles, tileCoordsStyles, tileWidthheights)
import Views.Level.Tile exposing (TileViewModel, renderTile_)
import Views.Level.TopBar exposing (topBar)


levelView : LevelModel -> Html LevelMsg
levelView model =
    div [ handleStop model, handleCheck model, class <| disableIfComplete model ]
        [ topBar model
        , renderInfoWindow model
        , board model
        , handleLineDrag model
        , div [ class "w-100 h-100 fixed z-1 top-0" ] [ backdrop ]
        ]


disableIfComplete : LevelModel -> String
disableIfComplete model =
    if not <| model.levelStatus == InProgress then
        "touch-disabled"

    else
        ""


board : LevelModel -> Html LevelMsg
board model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : LevelModel -> List (Html LevelMsg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


renderLines : LevelModel -> List (Html msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLine model.shared.window)


boardLayout : LevelModel -> List (Html LevelMsg) -> Html LevelMsg
boardLayout { shared, boardDimensions } =
    div
        [ style
            [ width <| toFloat <| boardWidth shared.window boardDimensions
            , boardMarginTop shared.window boardDimensions
            ]
        , class "relative z-3 center flex flex-wrap"
        ]


renderTile : LevelModel -> Move -> Html LevelMsg
renderTile model move =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        ]
        [ renderTile_ (leavingStyles model move) <| tileModelSelector model move ]


handleStop : LevelModel -> Attribute LevelMsg
handleStop model =
    if model.isDragging then
        onPointerUp StopMove

    else
        emptyProperty


hanldeMoveEvents : LevelModel -> Move -> Attribute LevelMsg
hanldeMoveEvents model move =
    if not model.isDragging then
        onPointerDownPosition <| StartMove move

    else
        emptyProperty


handleCheck : LevelModel -> Attribute LevelMsg
handleCheck model =
    if model.isDragging then
        onPointerMovePosition CheckMove

    else
        emptyProperty


renderInfoWindow : LevelModel -> Html msg
renderInfoWindow { infoWindow } =
    let
        infoContent =
            val infoWindow |> Maybe.withDefault ""
    in
    if isHidden infoWindow then
        span [] []

    else
        infoContainer infoWindow <|
            div [ class "pv5 f3 tracked-mega" ] [ text infoContent ]


tileModelSelector : LevelModel -> Move -> TileViewModel
tileModelSelector levelModel move =
    { move = move
    , window = levelModel.shared.window
    , boardDimensions = levelModel.boardDimensions
    , moveShape = levelModel.moveShape
    }
