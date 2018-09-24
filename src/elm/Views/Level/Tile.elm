module Views.Level.Tile exposing (..)

import Config.Scale exposing (tileScaleFactor)
import Data.Board.Block as Block
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Html exposing (emptyProperty, onPointerDownPosition, preventDefault)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Types as Level exposing (..)
import Views.Level.Styles exposing (..)
import Views.Seed.All exposing (renderSeed)
import Window exposing (Size)


renderTile : LevelModel -> Move -> Html LevelMsg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        ]
        [ renderTile_ (leavingStyles model move) model move ]


renderTile_ : List Style -> TileConfig model -> Move -> Html msg
renderTile_ extraStyles config (( ( y, x ) as coord, tile ) as move) =
    div
        [ styles
            [ tileWidthHeightStyles config
            , tileCoordsStyles config coord
            , extraStyles
            ]
        , attribute "touch-action" "none"
        , class "dib absolute"
        ]
        [ innerTile config.window config.moveShape move
        , tracer config.window move
        , wall config.window move
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
    div [ style <| wallStyles window move, class centerBlock ] []


innerTile : Window.Size -> Maybe MoveShape -> Move -> Html msg
innerTile window moveShape move =
    makeInnerTile (draggingStyles moveShape move) window move


makeInnerTile : List Style -> Window.Size -> Move -> Html msg
makeInnerTile extraStyles window (( _, tile ) as move) =
    div
        [ classes baseTileClasses
        , styles [ extraStyles, baseTileStyles window move ]
        ]
        [ innerSeed tile ]


baseTileStyles : Window.Size -> Move -> List Style
baseTileStyles window (( _, tile ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , widthHeight <| round <| tileSizeMap tile * tileScaleFactor window
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
