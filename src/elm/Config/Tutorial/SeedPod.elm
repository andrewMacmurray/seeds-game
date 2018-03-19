module Config.Tutorial.SeedPod exposing (..)

import Data.Level.Tutorial exposing (addBlock, seedPodBoard)
import Data.Board exposing (Board)
import Data.Level.Settings exposing (BoardDimensions)
import Data.Board.Tile exposing (..)
import Dict exposing (Dict)
import Scenes.Tutorial.Types as Tutorial exposing (..)


config : Config
config =
    { text = text
    , boardDimensions = boardDimensions
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Seed Sunflower
    }


initialBoard : Board
initialBoard =
    seedPodBoard boardDimensions


boardDimensions : BoardDimensions
boardDimensions =
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
