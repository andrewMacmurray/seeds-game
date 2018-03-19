module Data.Tutorial exposing (..)

import Data2.Block exposing (Block(..))
import Data2.Board exposing (Board, Coord)
import Data2.Board.Generate exposing (makeBoard)
import Data2.Level.Settings exposing (BoardDimensions)
import Data2.Tile exposing (TileType(..), SeedType(..))
import Data2.TileState exposing (TileState(..))
import Dict exposing (Dict)


getText : Dict Int String -> Int -> String
getText tutorialText n =
    Dict.get n tutorialText |> Maybe.withDefault ""


addBlock : Coord -> TileType -> Board -> Board
addBlock coord tileType board =
    board |> Dict.insert coord (Space (Static tileType))


sunBoard : BoardDimensions -> Board
sunBoard =
    monoBoard Sun


rainBoard : BoardDimensions -> Board
rainBoard =
    monoBoard Rain


seedBoard : BoardDimensions -> Board
seedBoard =
    monoBoard <| Seed Sunflower


seedPodBoard : BoardDimensions -> Board
seedPodBoard =
    monoBoard SeedPod


monoBoard : TileType -> BoardDimensions -> Board
monoBoard tileType ({ x, y } as scale) =
    makeBoard scale <| List.repeat (x * y) tileType
