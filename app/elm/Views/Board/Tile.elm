module Views.Board.Tile exposing (..)

import Data.Level.Board.Tile exposing (tileColorMap, tileSize, tileSizeMap)
import Helpers.Html exposing (onMouseDownPreventDefault)
import Helpers.Style exposing (Style, classes, styles)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter)
import Scenes.Level.Types as Level exposing (..)
import Views.Board.Styles exposing (..)


renderTile : Level.Model -> Move -> Html Level.Msg
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
            [ tileWidthHeightStyles config.tileSize
            , tileCoordsStyles config.tileSize coord
            , extraStyles
            ]
        , class "dib absolute"
        ]
        [ innerTile config.seedType config.moveShape move
        , tracer config.seedType move
        , wall move
        ]


hanldeMoveEvents : Level.Model -> Move -> Attribute Level.Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDownPreventDefault <| StartMove move


tracer : SeedType -> Move -> Html msg
tracer seedType move =
    makeInnerTile (moveTracerStyles move) seedType move


wall : Move -> Html msg
wall move =
    div [ style <| wallStyles move, class centerBlock ] []


innerTile : SeedType -> Maybe MoveShape -> Move -> Html msg
innerTile seedType moveShape move =
    makeInnerTile (draggingStyles moveShape move) seedType move


makeInnerTile : List Style -> SeedType -> Move -> Html msg
makeInnerTile extraStyles seedType (( _, tile ) as move) =
    div
        [ classes baseTileClasses
        , styles [ extraStyles, baseTileStyles seedType move ]
        ]
        []


baseTileStyles : SeedType -> Move -> List Style
baseTileStyles seedType (( _, tile ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , releasingStyles move
        , tileSizeMap tile
        , tileColorMap seedType tile
        ]
