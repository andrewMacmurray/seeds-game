module Views.Level.Board exposing (..)

import Dict
import Helpers.Html exposing (emptyProperty, onMouseDownPreventDefault)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter, onMouseUp)
import Scenes.Level.Types exposing (..)
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


renderLines : BoardConfig model -> List (Html msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLineLayer model.tileSize)


boardLayout : Level.Model -> List (Html Level.Msg) -> Html Level.Msg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ widthStyle <| boardWidth model.tileSize model.boardScale
            , boardMarginTop model
            ]
        ]


renderLineLayer : TileSize -> Move -> Html msg
renderLineLayer tileSize (( coord, _ ) as move) =
    div
        [ styles
            [ tileWidthHeightStyles tileSize
            , tileCoordsStyles tileSize coord
            ]
        , class "dib absolute touch-disabled"
        ]
        [ renderLine move
        ]


handleStop : Level.Model -> Attribute Level.Msg
handleStop model =
    if model.isDragging && model.moveShape /= Just Square then
        onMouseUp <| StopMove Line
    else
        emptyProperty
