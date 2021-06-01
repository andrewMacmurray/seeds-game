module Scene.Level.Board.Tile exposing (view)

import Board
import Board.Block as Block exposing (Block)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Css.Style as Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Level.Setting.Tile as Tile
import Scene.Level.Board.Tile.Leaving as Leaving
import Scene.Level.Board.Tile.Style as Tile
import View.Icon.Burst as Burst
import View.Seed as Seed
import Window exposing (Window)



-- Model


type alias Model =
    { isBursting : Bool
    , window : Window
    , withTracer : Bool
    , tileSettings : List Tile.Setting
    , boardSize : Board.Size
    }



-- View


view : Model -> Move -> Html msg
view ({ window } as model) move =
    div
        [ styles
            [ Tile.widthHeightStyles window
            , Tile.coordStyles window (Move.coord move)
            , Leaving.styles (leavingViewModel model) move
            ]
        , class "dib absolute"
        ]
        [ innerTile model.isBursting window move
        , renderIf model.withTracer (tracer window move)
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
    innerTileWithStyles (Tile.moveTracerStyles move) window move


wall : Window -> Move -> Html msg
wall window move =
    div
        [ style <| Tile.wallStyles window move
        , class Tile.centerBlock
        ]
        []


innerTile : Bool -> Window -> Move -> Html msg
innerTile isBursting window move =
    innerTileWithStyles
        (Tile.draggingStyles isBursting move)
        window
        move


innerTileWithStyles : List Style -> Window -> Move -> Html msg
innerTileWithStyles extraStyles window move =
    div
        [ styles
            [ extraStyles
            , baseTileStyles window move
            ]
        , classes Tile.baseClasses
        ]
        [ innerTileElement (Move.block move) ]


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
        , size <| roundFloat <| Tile.size block * Tile.scale window
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
            span [] []


renderBurst : Block -> Maybe Tile -> Html msg
renderBurst block tile =
    div [ Style.style <| Tile.burstStyles block ]
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



-- View Models


leavingViewModel : Model -> Leaving.Model
leavingViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , tileSettings = model.tileSettings
    }
