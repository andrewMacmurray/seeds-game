module Data.Level.Board.Block exposing (..)

import Dict
import Scenes.Level.Types exposing (..)


addWalls : List ( WallColor, Coord ) -> Board -> Board
addWalls coords board =
    List.foldl
        (\( wallColor, coord ) currentBoard ->
            Dict.update coord (Maybe.map (always <| Wall wallColor)) currentBoard
        )
        board
        coords


getTileState : Block -> TileState
getTileState =
    fold identity Empty


isWall : Block -> Bool
isWall block =
    case block of
        Wall _ ->
            True

        _ ->
            False


map : (TileState -> TileState) -> Block -> Block
map fn block =
    case block of
        Space tileState ->
            Space <| fn tileState

        wall ->
            wall


fold : (TileState -> a) -> a -> Block -> a
fold fn default block =
    case block of
        Wall _ ->
            default

        Space tileState ->
            fn tileState
