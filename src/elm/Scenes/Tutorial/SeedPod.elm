module Scenes.Tutorial.SeedPod exposing (config)

import Data.Board.Generate as Board
import Data.Board.Types exposing (..)
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial exposing (..)


config : Tutorial.Config
config =
    { text = text
    , boardDimensions = dimensions
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Seed Sunflower
    }


initialBoard : Board
initialBoard =
    Board.mono SeedPod dimensions


dimensions : BoardDimensions
dimensions =
    { x = 3, y = 3 }


text : Dict Int String
text =
    Dict.fromList
        [ ( 1, "Green pods can be grown into seeds" )
        ]


sequence : Tutorial.Sequence
sequence =
    [ ( 500, ShowContainer )
    , ( 1500, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 2, 1 ) )
    , ( 1500, SetGrowingPods )
    , ( 800, GrowPods Sunflower )
    , ( 600, ResetGrowingPods )
    , ( 1500, HideCanvas )
    , ( 1500, ExitTutorial )
    ]
