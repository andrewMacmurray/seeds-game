module Views.Board.Tile exposing (renderTile_)

import Css.Color as Color
import Css.Style as Style exposing (..)
import Data.Board.Block as Block
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Window exposing (Window)
import Html exposing (..)
import Html.Attributes exposing (attribute, class)
import Views.Board.Styles exposing (..)
import Views.Icons.Burst as Burst
import Views.Seed.All exposing (renderSeed)


type alias Settings =
    { extraStyles : List Style
    , externalDragTriggered : Bool
    , burstMagnitude : Int
    , withTracer : Bool
    }


renderTile_ : Settings -> Window -> Move -> Html msg
renderTile_ { extraStyles, externalDragTriggered, burstMagnitude, withTracer } window (( coord, _ ) as move) =
    div
        [ styles
            [ tileWidthheights window
            , tileCoordsStyles window coord
            , extraStyles
            ]
        , class "dib absolute"
        ]
        [ innerTile externalDragTriggered window move
        , renderIf withTracer <| tracer burstMagnitude window move
        , wall window move
        ]


renderIf predicate element =
    if predicate then
        element

    else
        span [] []


tracer : Int -> Window -> Move -> Html msg
tracer burstMagnitude window move =
    innerTileWithStyles (moveTracerStyles move ++ burstTracerStyles burstMagnitude move) window move


wall : Window -> Move -> Html msg
wall window move =
    div
        [ style <| wallStyles window move
        , class centerBlock
        ]
        []


innerTile : Bool -> Window -> Move -> Html msg
innerTile externalDragTriggered window move =
    innerTileWithStyles (draggingStyles externalDragTriggered move) window move


innerTileWithStyles : List Style -> Window -> Move -> Html msg
innerTileWithStyles extraStyles window (( _, block ) as move) =
    div
        [ styles
            [ extraStyles
            , baseTileStyles window move
            ]
        , classes baseTileClasses
        ]
        [ innerTileElement block ]


baseTileStyles : Window -> Move -> List Style
baseTileStyles window (( _, block ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , size <| toFloat <| round <| tileSizeMap block * Tile.scale window
        , tileBackgroundMap block
        ]


innerTileElement : Block -> Html msg
innerTileElement block =
    case Block.getTileType block of
        Just (Seed seedType) ->
            renderSeed seedType

        Just (Burst tile) ->
            div [ Style.style <| burstStyles block ]
                [ renderBurst tile <| Block.isLeaving block ]

        _ ->
            span [] []


renderBurst tile shouldDisperse =
    case tile of
        Just t ->
            if shouldDisperse then
                Burst.active (strokeColors t) (strokeColors t)

            else
                Burst.active (strokeColors t) (lighterStrokeColor t)

        Nothing ->
            Burst.inactive
