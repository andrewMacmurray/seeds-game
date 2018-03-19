module Views.Level.Tile exposing (..)

import Config.Scale exposing (tileScaleFactor)
import Data.Board exposing (Move)
import Data.Board.TileState exposing (MoveShape)
import Helpers.Html exposing (onMouseDownPreventDefault)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter)
import Scenes.Level.Types as Level exposing (..)
import Views.Level.Styles exposing (..)
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
        [ innerTile config.window config.moveShape move
        , tracer config.window move
        , wall config.window move
        ]


hanldeMoveEvents : Level.Model -> Move -> Attribute Level.Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDownPreventDefault <| StartMove move


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
        []


baseTileStyles : Window.Size -> Move -> List Style
baseTileStyles window (( _, tile ) as move) =
    List.concat
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , widthHeight <| round <| tileSizeMap tile * tileScaleFactor window
        , tileColorMap tile
        ]
