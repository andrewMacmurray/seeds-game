module Views.Board.Tile exposing (renderTile_)

import Css.Color as Color
import Css.Style as Style exposing (..)
import Data.Board.Block as Block
import Data.Board.Move as Move
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
    , isBursting : Bool
    , burstMagnitude : Int
    , withTracer : Bool
    }


renderTile_ : Settings -> Window -> Move -> Html msg
renderTile_ { extraStyles, isBursting, burstMagnitude, withTracer } window move =
    let
        coord =
            Move.coord move
    in
    div
        [ styles
            [ tileWidthheights window
            , tileCoordsStyles window coord
            , extraStyles
            ]
        , class "dib absolute"
        ]
        [ innerTile isBursting burstMagnitude window move
        , renderIf withTracer <| tracer burstMagnitude window move
        , wall window move
        ]


renderIf : Bool -> Html msg -> Html msg
renderIf predicate element =
    if predicate then
        element

    else
        span [] []


tracer : Int -> Window -> Move -> Html msg
tracer burstMagnitude window move =
    innerTileWithStyles
        (moveTracerStyles move ++ burstTracerStyles burstMagnitude move)
        burstMagnitude
        window
        move


wall : Window -> Move -> Html msg
wall window move =
    div
        [ style <| wallStyles window move
        , class centerBlock
        ]
        []


innerTile : Bool -> Int -> Window -> Move -> Html msg
innerTile isBursting burstMagnitude window move =
    innerTileWithStyles
        (draggingStyles isBursting move)
        burstMagnitude
        window
        move


innerTileWithStyles : List Style -> Int -> Window -> Move -> Html msg
innerTileWithStyles extraStyles burstMagnitude window move =
    div
        [ styles
            [ extraStyles
            , baseTileStyles window move burstMagnitude
            ]
        , classes baseTileClasses
        ]
        [ innerTileElement burstMagnitude <| Move.block move ]


baseTileStyles : Window -> Move -> Int -> List Style
baseTileStyles window move magnitude =
    let
        block =
            Move.block move
    in
    List.concat
        [ growingStyles move
        , burstingStyles magnitude move
        , enteringStyles move
        , fallingStyles move
        , size <| roundFloat <| tileSize block * Tile.scale window
        , tileBackground block
        ]


roundFloat : Float -> Float
roundFloat =
    round >> toFloat


innerTileElement : Int -> Block -> Html msg
innerTileElement burstMagnitude block =
    case Block.getTileType block of
        Just (Seed seedType) ->
            renderSeed seedType

        Just (Burst tile) ->
            div []
                [ renderBurst tile <| Block.isLeaving block ]

        _ ->
            span [] []


renderBurst : Maybe TileType -> Bool -> Html msg
renderBurst tile isBursting =
    case tile of
        Just tile_ ->
            if isBursting then
                Burst.active (strokeColors tile_) (strokeColors tile_)

            else
                Burst.active (strokeColors tile_) (lighterStrokeColor tile_)

        Nothing ->
            Burst.inactive
