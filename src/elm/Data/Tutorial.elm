module Data.Tutorial exposing
    ( addBlock
    , getText
    , rainBoard
    , seedBoard
    , seedPodBoard
    , sunBoard
    )

import Data.Board.Generate exposing (makeBoard)
import Data.Board.Types exposing (..)
import Dict exposing (Dict)


getText : Dict Int String -> Int -> String
getText textDict n =
    Dict.get n textDict |> Maybe.withDefault ""


addBlock : Coord -> TileType -> Board -> Board
addBlock coord tileType board =
    board |> Dict.insert coord (staticTile tileType)


staticTile : TileType -> Block
staticTile =
    Static >> Space


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
