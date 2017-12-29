module Views.Board.Tile exposing (..)

import Data.Level.Board.Tile exposing (tileColorMap, tileSize, tileSizeMap)
import Data.Level.Scale exposing (tileScaleFactor)
import Helpers.Html exposing (onMouseDownPreventDefault)
import Helpers.Style exposing (Style, classes, styles, widthHeight, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter)
import Scenes.Level.Types as Level exposing (..)
import Views.Board.Styles exposing (..)
import Window exposing (Size)


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
            [ tileWidthHeightStyles config
            , tileCoordsStyles config coord
            , extraStyles
            ]
        , class "dib absolute"
        ]
        [ innerTile config.window config.seedType config.moveShape move
        , tracer config.window config.seedType move
        , wall config.window move
        ]


hanldeMoveEvents : Level.Model -> Move -> Attribute Level.Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDownPreventDefault <| StartMove move


tracer : Window.Size -> SeedType -> Move -> Html msg
tracer window seedType move =
    makeInnerTile (moveTracerStyles move) window seedType move


wall : Window.Size -> Move -> Html msg
wall window move =
    div [ style <| wallStyles window move, class centerBlock ] []


innerTile : Window.Size -> SeedType -> Maybe MoveShape -> Move -> Html msg
innerTile window seedType moveShape move =
    makeInnerTile (draggingStyles moveShape move) window seedType move


makeInnerTile : List Style -> Window.Size -> SeedType -> Move -> Html msg
makeInnerTile extraStyles window seedType (( _, tile ) as move) =
    div
        [ classes baseTileClasses
        , styles [ extraStyles, baseTileStyles window seedType move ]
        ]
        []


baseTileStyles : Window.Size -> SeedType -> Move -> List Style
baseTileStyles window seedType (( _, tile ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , releasingStyles move
        , widthHeight <| round <| tileSizeMap tile * tileScaleFactor window
        , tileColorMap seedType tile
        ]
