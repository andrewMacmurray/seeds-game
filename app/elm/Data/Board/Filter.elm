module Data.Board.Filter exposing (..)

import Data.Moves.Type exposing (currentMoveType)
import Data.Tiles exposing (getTileType, setStaticToDragging)
import Dict
import Model exposing (..)


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


setAllTilesOfTypeToDragging : Board -> Board
setAllTilesOfTypeToDragging board =
    board
        |> currentMoveType
        |> Maybe.map (allTilesOfType board)
        |> Maybe.withDefault board


allTilesOfType : Board -> TileType -> Board
allTilesOfType board tileType =
    board
        |> Dict.map
            (\_ tile ->
                if getTileType tile == Just tileType then
                    setStaticToDragging 1 tile
                else
                    tile
            )
