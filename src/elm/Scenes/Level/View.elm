module Scenes.Level.View exposing (levelView)

import Config.Scale as ScaleConfig
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale, translate)
import Css.Transition exposing (delay, transitionAll)
import Data.Board.Block exposing (getTileState, isLeaving, leavingOrder)
import Data.Board.Score as Score exposing (scoreTileTypes)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.InfoWindow as InfoWindow
import Data.Pointer exposing (onPointerDown, onPointerMove, onPointerUp)
import Data.Window as Window
import Dict
import Helpers.Html exposing (emptyProperty)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (attribute, class)
import Scenes.Level.Types exposing (..)
import Views.Backdrop exposing (backdrop)
import Views.InfoWindow exposing (infoContainer)
import Views.Level.Line exposing (renderLine)
import Views.Level.LineDrag exposing (LineViewModel, handleLineDrag)
import Views.Level.Styles exposing (TileViewModel, boardMarginTop, boardOffsetTop, boardWidth, tileCoordsStyles, tileWidthheights)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (TopBarViewModel, remainingMoves, topBar)


levelView : LevelModel -> Html LevelMsg
levelView model =
    div
        [ handleStop model
        , handleCheck model
        , disableIfComplete model
        ]
        [ topBar <| topBarViewModel model
        , renderInfoWindow model
        , board model
        , handleLineDrag <| lineViewModel model
        , div [ class "w-100 h-100 fixed z-1 top-0" ] [ backdrop ]
        ]


handleStop : LevelModel -> Attribute LevelMsg
handleStop model =
    applyIf model.isDragging <| onPointerUp StopMove


handleCheck : LevelModel -> Attribute LevelMsg
handleCheck model =
    applyIf model.isDragging <| onPointerMove CheckMove


disableIfComplete : LevelModel -> Attribute msg
disableIfComplete model =
    applyIf (not <| model.levelStatus == InProgress) <| class "touch-disabled"


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf predicate attr =
    if predicate then
        attr

    else
        emptyProperty


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


renderTile : LevelModel -> Move -> Html LevelMsg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        , attribute "touch-action" "none"
        ]
        [ renderTile_ (leavingStyles model move) model.shared.window model.moveShape move ]


renderLines : LevelModel -> List (Html msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLineLayer model.shared.window)


boardLayout : LevelModel -> List (Html msg) -> Html msg
boardLayout model =
    div
        [ style
            [ width <| toFloat <| boardWidth <| tileViewModel model
            , boardMarginTop <| tileViewModel model
            ]
        , class "relative z-3 center flex flex-wrap"
        ]


renderLineLayer : Window.Size -> Move -> Html msg
renderLineLayer window (( coord, _ ) as move) =
    div
        [ styles
            [ tileWidthheights window
            , tileCoordsStyles window coord
            ]
        , class "dib absolute touch-disabled"
        ]
        [ renderLine window move ]


hanldeMoveEvents : LevelModel -> Move -> Attribute LevelMsg
hanldeMoveEvents model move =
    applyIf (not model.isDragging) <| onPointerDown <| StartMove move


renderInfoWindow : LevelModel -> Html msg
renderInfoWindow { infoWindow } =
    let
        infoContent =
            InfoWindow.val infoWindow |> Maybe.withDefault ""
    in
    if InfoWindow.isHidden infoWindow then
        span [] []

    else
        infoContainer infoWindow <|
            div [ class "pv5 f3 tracked-mega" ] [ text infoContent ]


leavingStyles : LevelModel -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionAll 800 [ delay <| modBy 5 (leavingOrder tile) * 80 ]
        , opacity 0.2
        , handleExitDirection move model
        ]

    else
        []


handleExitDirection : Move -> LevelModel -> Style
handleExitDirection ( coord, block ) model =
    case getTileState block of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            Style.empty


getLeavingStyle : TileType -> LevelModel -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault empty


newLeavingStyles : LevelModel -> Dict.Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : LevelModel -> Int -> TileType -> ( String, Style )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , transform
        [ translate (exitXDistance resourceBankIndex model) -(exitYdistance (tileViewModel model))
        , scale 0.5
        ]
    )


exitXDistance : Int -> LevelModel -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            ScaleConfig.scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Score.collectable
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (boardWidth (tileViewModel model) - scoreBarWidth) // 2

        offset =
            exitOffsetFunction <| ScaleConfig.tileScaleFactor model.shared.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffsetFunction : Float -> Float
exitOffsetFunction x =
    25 * (x ^ 2) - (75 * x) + ScaleConfig.baseTileSizeX


exitYdistance : TileViewModel -> Float
exitYdistance model =
    toFloat (boardOffsetTop model) - 9


tileViewModel : LevelModel -> TileViewModel
tileViewModel model =
    ( model.shared.window
    , model.boardDimensions
    )


topBarViewModel : LevelModel -> TopBarViewModel
topBarViewModel model =
    { window = model.shared.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineViewModel : LevelModel -> LineViewModel
lineViewModel model =
    { window = model.shared.window
    , board = model.board
    , boardDimensions = model.boardDimensions
    , isDragging = model.isDragging
    , pointer = model.pointer
    }
