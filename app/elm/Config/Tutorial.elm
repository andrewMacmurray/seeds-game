module Config.Tutorial exposing (..)

import Data.Level.Board.Make exposing (makeBoard)
import Dict exposing (Dict)
import Scenes.Level.Types exposing (..)


getText : Int -> String
getText n =
    Dict.get n tutorialText |> Maybe.withDefault ""


tutorialText : Dict Int String
tutorialText =
    Dict.fromList
        [ ( 1, "Connect seed pods to grow seeds" )
        , ( 2, "Fill the seed bank with seeds" )
        ]


tutorialBoard1 : Board
tutorialBoard1 =
    seedPodBoard 2


tutorialBoard2 : Board
tutorialBoard2 =
    seedPodBoard 3
        |> Dict.insert ( 0, 0 ) (space Seed)
        |> Dict.insert ( 0, 1 ) (space Seed)
        |> Dict.insert ( 1, 1 ) (space Seed)
        |> Dict.insert ( 2, 1 ) (space Seed)


space : TileType -> Block
space =
    Space << Static


seedPodBoard : Int -> Board
seedPodBoard n =
    makeBoard n <| List.repeat (n * n) SeedPod
