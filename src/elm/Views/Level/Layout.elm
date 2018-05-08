module Views.Level.Layout exposing (..)

import Data.Board.Types exposing (Move, TileConfig)
import Dict
import Helpers.Css.Style exposing (..)
import Helpers.Html exposing (emptyProperty, onMouseDownPreventDefault)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter, onMouseUp)
import Scenes.Level.Types as Level exposing (..)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (..)
import Views.Level.Tile exposing (..)


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
        |> List.map (renderLineLayer model)


boardLayout : LevelModel -> List (Html LevelMsg) -> Html LevelMsg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ widthStyle <| boardWidth model
            , boardMarginTop model
            ]
        ]


renderLineLayer : TileConfig model -> Move -> Html msg
renderLineLayer model (( coord, _ ) as move) =
    div
        [ styles
            [ tileWidthHeightStyles model
            , tileCoordsStyles model coord
            ]
        , class "dib absolute touch-disabled"
        ]
        [ renderLine model.window move
        ]


handleStop : LevelModel -> Attribute LevelMsg
handleStop model =
    if model.isDragging then
        onMouseUp StopMove
    else
        emptyProperty
