module Scene.Level.Board.Tile2 exposing (view)

import Board
import Board.Block as Block exposing (Block)
import Board.Coord as Coord exposing (Coord)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Css.Style as Style exposing (Style)
import Element exposing (..)
import Html exposing (Html)
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Leaving as Leaving
import Scene.Level.Board.Tile.Style as Tile
import Scene.Level.Board.Tile.Wall as Wall
import Utils.Element as Element
import View.Icon.Burst as Burst
import View.Seed as Seed
import Window exposing (Window)



-- Model


type alias Model =
    { isBursting : Bool
    , window : Window
    , withTracer : Bool
    , settings : List Tile.Setting
    , boardSize : Board.Size
    }



-- View


view : Model -> Move -> Element msg
view ({ window } as model) move =
    column
        [ width (px (tileWidth window))
        , height (px (tileHeight window))
        , moveRight (offsetX window move)
        , moveDown (offsetY window move)
        ]
        [ html (innerTile model.isBursting window move)
        , Element.showIf model.withTracer (tracer window move)
        , wall window move
        ]


tracer : Window -> Move -> Element msg
tracer window move =
    html
        (innerTileWithStyles
            (Tile.moveTracerStyles move)
            window
            move
        )


wall : Window -> Move -> Element msg
wall window move =
    Wall.view
        { window = window
        , move = move
        }


innerTile : Bool -> Window -> Move -> Html msg
innerTile isBursting window move =
    innerTileWithStyles
        (Tile.draggingStyles isBursting move)
        window
        move


innerTileWithStyles : List Style -> Window -> Move -> Html msg
innerTileWithStyles extraStyles window move =
    Html.div
        [ Style.styles
            [ extraStyles
            , baseTileStyles window move
            ]
        , Style.classes Tile.baseClasses
        ]
        [ innerTileElement <| Move.block move ]


baseTileStyles : Window -> Move -> List Style
baseTileStyles window move =
    let
        block =
            Move.block move
    in
    List.concat
        [ Tile.growingStyles move
        , Tile.enteringStyles move
        , Tile.fallingStyles move
        , Tile.releasingStyles move
        , Style.size <| roundFloat <| Tile.size block * Tile.scale window
        , Tile.background block
        ]


roundFloat : Float -> Float
roundFloat =
    round >> toFloat


innerTileElement : Block -> Html msg
innerTileElement block =
    case Block.tile block of
        Just (Tile.Seed seedType) ->
            Seed.view seedType

        Just (Tile.Burst tile) ->
            renderBurst block tile

        _ ->
            Html.span [] []


renderBurst : Block -> Maybe Tile -> Html msg
renderBurst block tile =
    Html.div [ Style.style <| Tile.burstStyles block ]
        [ renderBurst_ tile <| Block.isLeaving block ]


renderBurst_ : Maybe Tile -> Bool -> Html msg
renderBurst_ tile isLeaving =
    case tile of
        Just tile_ ->
            if isLeaving then
                Burst.active (Tile.strokeColors tile_) (Tile.strokeColors tile_)

            else
                Burst.active (Tile.strokeColors tile_) (Tile.lighterStrokeColor tile_)

        Nothing ->
            Burst.inactive



-- Config


tileWidth : Window -> Int
tileWidth window =
    round (Tile.baseSizeX * Tile.scale window)


tileHeight : Window -> Int
tileHeight window =
    round (Tile.baseSizeY * Tile.scale window)


offsetX window =
    Move.coord >> position window >> .x


offsetY window =
    Move.coord >> position window >> .y


position : Window -> Coord -> { x : Float, y : Float }
position window coord =
    { x = toFloat (Coord.x coord * tileWidth window)
    , y = toFloat (Coord.y coord * tileHeight window)
    }



-- View Models


leavingViewModel : Model -> Leaving.ViewModel
leavingViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , tileSettings = model.settings
    }
