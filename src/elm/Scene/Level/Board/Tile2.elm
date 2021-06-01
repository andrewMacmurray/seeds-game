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
import Scene.Level.Board.Tile.Leaving2 as Leaving
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
    , move : Move
    }



-- View


view : Model -> Element msg
view ({ window, move } as model) =
    column
        (List.append
            [ width (px (tileWidth window))
            , height (px (tileHeight window))
            , inFront (tracer model)
            ]
            (Leaving.attributes (leavingViewModel model)
                [ moveRight (offsetX model)
                , moveDown (offsetY model)
                ]
            )
        )
        [ innerTile model
        , wall model
        ]


tracer : Model -> Element msg
tracer model =
    Element.showIf model.withTracer (tracer_ model)


tracer_ : Model -> Element msg
tracer_ model =
    innerTileWithStyles (Tile.moveTracerStyles model.move) model


wall : Model -> Element msg
wall model =
    Wall.view
        { window = model.window
        , move = model.move
        }


innerTile : Model -> Element msg
innerTile model =
    innerTileWithStyles (Tile.draggingStyles model.isBursting model.move) model


innerTileWithStyles : List Style -> Model -> Element msg
innerTileWithStyles extraStyles model =
    html
        (Html.div
            [ Style.styles
                [ extraStyles
                , baseTileStyles model
                ]
            , Style.classes Tile.baseClasses
            ]
            [ innerTileElement (Move.block model.move) ]
        )


baseTileStyles : Model -> List Style
baseTileStyles { move, window } =
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
    Html.div
        [ Style.style (Tile.burstStyles block) ]
        [ renderBurst_ tile (Block.isLeaving block) ]


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


offsetX : Model -> Float
offsetX model =
    model.move
        |> Move.coord
        |> position model.window
        |> .x


offsetY : Model -> Float
offsetY model =
    model.move
        |> Move.coord
        |> position model.window
        |> .y


position : Window -> Coord -> { x : Float, y : Float }
position window coord =
    { x = toFloat (Coord.x coord * tileWidth window)
    , y = toFloat (Coord.y coord * tileHeight window)
    }



-- View Models


leavingViewModel : Model -> Leaving.Model
leavingViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , settings = model.settings
    , move = model.move
    }
