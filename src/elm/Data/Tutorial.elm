module Data.Tutorial exposing (..)

import Data.Level.Board.Generate exposing (makeBoard)
import Dict exposing (Dict)
import Scenes.Level.Types exposing (..)


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
