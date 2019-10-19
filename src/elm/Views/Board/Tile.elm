module Views.Board.Tile exposing (view)

import Css.Style as Style exposing (..)
import Data.Board.Block as Block
import Data.Board.Move as Move
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Window exposing (Window)
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.Board.Tile.Styles exposing (..)
import Views.Icons.Burst as Burst
import Views.Seed.All exposing (renderSeed)


type alias Settings =
    { extraStyles : List Style
    , isBursting : Bool
    , withTracer : Bool
    }


view : Settings -> Window -> Move -> Html msg
view { extraStyles, isBursting, withTracer } window move =
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
        [ innerTile isBursting window move
        , renderIf withTracer <| tracer window move
        , wall window move
        ]


renderIf : Bool -> Html msg -> Html msg
renderIf predicate element =
    if predicate then
        element

    else
        span [] []


tracer : Window -> Move -> Html msg
tracer window move =
    innerTileWithStyles
        (moveTracerStyles move)
        window
        move


wall : Window -> Move -> Html msg
wall window move =
    div
        [ style <| wallStyles window move
        , class centerBlock
        ]
        []


innerTile : Bool -> Window -> Move -> Html msg
innerTile isBursting window move =
    innerTileWithStyles
        (draggingStyles isBursting move)
        window
        move


innerTileWithStyles : List Style -> Window -> Move -> Html msg
innerTileWithStyles extraStyles window move =
    div
        [ styles
            [ extraStyles
            , baseTileStyles window move
            ]
        , classes baseTileClasses
        ]
        [ innerTileElement <| Move.block move ]


baseTileStyles : Window -> Move -> List Style
baseTileStyles window move =
    let
        block =
            Move.block move
    in
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , activeStyles move
        , size <| roundFloat <| tileSize block * Tile.scale window
        , tileBackground block
        ]


roundFloat : Float -> Float
roundFloat =
    round >> toFloat


innerTileElement : Block -> Html msg
innerTileElement block =
    case Block.tileType block of
        Just (Seed seedType) ->
            renderSeed seedType

        Just (Burst tile) ->
            renderBurst block tile

        _ ->
            span [] []


renderBurst : Block -> Maybe TileType -> Html msg
renderBurst block tile =
    div [ Style.style <| burstStyles block ]
        [ renderBurst_ tile <| Block.isLeaving block ]


renderBurst_ : Maybe TileType -> Bool -> Html msg
renderBurst_ tile isBursting =
    case tile of
        Just tile_ ->
            if isBursting then
                Burst.active (strokeColors tile_) (strokeColors tile_)

            else
                Burst.active (strokeColors tile_) (lighterStrokeColor tile_)

        Nothing ->
            Burst.inactive
