module Config.Tutorial exposing (..)

import Data.Level.Board.Make exposing (makeBoard)
import Scenes.Level.Types exposing (..)


tutorialBoard1 : Board
tutorialBoard1 =
    makeBoard 2
        [ SeedPod
        , SeedPod
        , SeedPod
        , SeedPod
        ]
