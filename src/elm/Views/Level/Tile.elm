module Views.Level.Tile exposing
    ( baseTileStyles
    , innerSeed
    , innerSeed_
    , innerTile
    , makeInnerTile
    , renderTile_
    , tileElementMap
    , tracer
    , wall
    )

import Css.Style as Style exposing (..)
import Data.Board.Block as Block
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Window exposing (Window)
import Html exposing (..)
import Html.Attributes exposing (attribute, class)
import Views.Level.Styles exposing (..)
import Views.Seed.All exposing (renderSeed)


renderTile_ : List Style -> Window -> Maybe MoveShape -> Move -> Html msg
renderTile_ extraStyles window moveShape (( coord, _ ) as move) =
    div
        [ styles
            [ tileWidthheights window
            , tileCoordsStyles window coord
            , extraStyles
            ]
        , class "dib absolute"
        ]
        [ innerTile window moveShape move
        , tracer window move
        , wall window move
        ]


tracer : Window -> Move -> Html msg
tracer window move =
    makeInnerTile (moveTracerStyles move) window move


wall : Window -> Move -> Html msg
wall window move =
    div
        [ style <| wallStyles window move
        , class centerBlock
        ]
        []


innerTile : Window -> Maybe MoveShape -> Move -> Html msg
innerTile window moveShape move =
    makeInnerTile (draggingStyles moveShape move) window move


makeInnerTile : List Style -> Window -> Move -> Html msg
makeInnerTile extraStyles window (( _, tile ) as move) =
    div
        [ styles
            [ extraStyles
            , baseTileStyles window move
            ]
        , classes baseTileClasses
        ]
        [ innerSeed tile ]


baseTileStyles : Window -> Move -> List Style
baseTileStyles window (( _, tile ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , size <| toFloat <| round <| tileSizeMap tile * Tile.scale window
        , tileBackgroundMap tile
        ]


innerSeed : Block -> Html msg
innerSeed =
    Block.fold (tileElementMap innerSeed_) <| span [] []


innerSeed_ : TileType -> Html msg
innerSeed_ tileType =
    case tileType of
        Seed seedType ->
            renderSeed seedType

        _ ->
            span [] []


tileElementMap : (TileType -> Html msg) -> TileState -> Html msg
tileElementMap =
    Tile.map <| span [] []
