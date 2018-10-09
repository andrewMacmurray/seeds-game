module Views.Level.Tile exposing
    ( baseTileStyles
    , hanldeMoveEvents
    , innerSeed
    , innerSeed_
    , innerTile
    , makeInnerTile
    , renderTile
    , renderTile_
    , tileElementMap
    , tracer
    , wall
    )

import Config.Scale exposing (tileScaleFactor)
import Css.Style as Style exposing (..)
import Data.Board.Block as Block
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Window as Window exposing (Size)
import Helpers.Html exposing (emptyProperty, onPointerDownPosition)
import Html exposing (..)
import Html.Attributes exposing (attribute, class)
import Scenes.Level.Types as Level exposing (..)
import Views.Level.Styles exposing (..)
import Views.Seed.All exposing (renderSeed)


renderTile : LevelModel -> Move -> Html LevelMsg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        ]
        [ renderTile_ (leavingStyles model move) model move ]


renderTile_ : List Style -> TileConfig model shared -> Move -> Html msg
renderTile_ extraStyles config (( ( y, x ) as coord, tile ) as move) =
    div
        [ styles
            [ tileWidthheights config
            , tileCoordsStyles config coord
            , extraStyles
            ]
        , attribute "touch-action" "none"
        , class "dib absolute"
        ]
        [ innerTile config.shared.window config.moveShape move
        , tracer config.shared.window move
        , wall config.shared.window move
        ]


hanldeMoveEvents : LevelModel -> Move -> Attribute LevelMsg
hanldeMoveEvents model move =
    if not model.isDragging then
        onPointerDownPosition <| StartMove move

    else
        emptyProperty


tracer : Window.Size -> Move -> Html msg
tracer window move =
    makeInnerTile (moveTracerStyles move) window move


wall : Window.Size -> Move -> Html msg
wall window move =
    div
        [ style <| wallStyles window move
        , class centerBlock
        ]
        []


innerTile : Window.Size -> Maybe MoveShape -> Move -> Html msg
innerTile window moveShape move =
    makeInnerTile (draggingStyles moveShape move) window move


makeInnerTile : List Style -> Window.Size -> Move -> Html msg
makeInnerTile extraStyles window (( _, tile ) as move) =
    div
        [ styles
            [ extraStyles
            , baseTileStyles window move
            ]
        , classes baseTileClasses
        ]
        [ innerSeed tile ]


baseTileStyles : Window.Size -> Move -> List Style
baseTileStyles window (( _, tile ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , widthHeight <| toFloat <| round <| tileSizeMap tile * tileScaleFactor window
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
