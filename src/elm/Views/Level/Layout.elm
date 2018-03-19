module Views.Level.Layout exposing (..)

import Data.Board exposing (Move)
import Dict
import Helpers.Html exposing (emptyProperty, onMouseDownPreventDefault)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter, onMouseUp)
import Scenes.Level.Types as Level exposing (..)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (..)
import Views.Level.Tile exposing (..)


board : Level.Model -> Html Level.Msg
board model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : Level.Model -> List (Html Level.Msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


renderLines : Level.Model -> List (Html msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLineLayer model)


boardLayout : Level.Model -> List (Html Level.Msg) -> Html Level.Msg
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


handleStop : Level.Model -> Attribute Level.Msg
handleStop model =
    if model.isDragging then
        onMouseUp StopMove
    else
        emptyProperty
