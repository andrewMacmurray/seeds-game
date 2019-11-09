module Scenes.Level.Board.Tile exposing (view)

import Board
import Board.Block as Block exposing (Block)
import Board.Move as Move exposing (Move)
import Board.Tile as Tile exposing (Tile)
import Css.Style as Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Level.Setting.Tile as Tile
import Scenes.Level.Board.Style as Board exposing (leaving)
import Scenes.Level.Board.Tile.Style as Tile exposing (..)
import Views.Icon.Burst as Burst
import Views.Seed as Seed
import Window exposing (Window)



-- Model


type alias ViewModel =
    { isBursting : Bool
    , window : Window
    , withTracer : Bool
    , tileSettings : List Tile.Setting
    , boardSize : Board.Size
    }



-- View


view : ViewModel -> Move -> Html msg
view ({ window } as model) move =
    div
        [ styles
            [ widthHeightStyles window
            , coordStyles window (Move.coord move)
            , leaving (boardViewModel model) move
            ]
        , class "dib absolute"
        ]
        [ innerTile model.isBursting window move
        , renderIf model.withTracer <| tracer window move
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
        , classes Tile.baseClasses
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
        , size <| roundFloat <| tileSize block * Tile.scale window
        , tileBackground block
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
    div [ Style.style <| burstStyles block ]
        [ renderBurst_ tile <| Block.isLeaving block ]


renderBurst_ : Maybe Tile -> Bool -> Html msg
renderBurst_ tile isLeaving =
    case tile of
        Just tile_ ->
            if isLeaving then
                Burst.active (strokeColors tile_) (strokeColors tile_)

            else
                Burst.active (strokeColors tile_) (lighterStrokeColor tile_)

        Nothing ->
            Burst.inactive



-- View Models


boardViewModel : ViewModel -> Board.ViewModel
boardViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    , tileSettings = model.tileSettings
    }
