module Config.Tutorial exposing (..)

import Data.Level.Board.Generate exposing (makeBoard)
import Dict exposing (Dict)
import Scenes.Level.Types exposing (..)


getText : Int -> String
getText n =
    Dict.get n tutorialText |> Maybe.withDefault ""


tutorialText : Dict Int String
tutorialText =
    Dict.fromList
        [ ( 1, "Connect seed pods to grow seeds" )
        , ( 2, "Collect enough seeds for the seed bank" )
        ]


tutorialBoard1 : Board
tutorialBoard1 =
    seedPodBoard { x = 2, y = 2 }


tutorialBoard2 : Board
tutorialBoard2 =
    seedPodBoard { x = 3, y = 3 }
        |> Dict.insert ( 0, 0 ) (space <| Seed Sunflower)
        |> Dict.insert ( 0, 1 ) (space <| Seed Sunflower)
        |> Dict.insert ( 1, 1 ) (space <| Seed Sunflower)
        |> Dict.insert ( 2, 1 ) (space <| Seed Sunflower)


space : TileType -> Block
space =
    Space << Static


seedPodBoard : BoardDimensions -> Board
seedPodBoard ({ x, y } as scale) =
    makeBoard scale <| List.repeat (x * y) SeedPod
