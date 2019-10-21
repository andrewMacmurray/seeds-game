module Scenes.Tutorial.SeedPod exposing (config)

import Data.Board as Board exposing (Board)
import Data.Board.Generate as Board
import Data.Board.Tile exposing (SeedType(..), Type(..))
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial exposing (..)


config : Tutorial.Config
config =
    { text = text
    , boardSize = boardSize
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Seed Chrysanthemum
    }


initialBoard : Board
initialBoard =
    Board.mono SeedPod boardSize


boardSize : Board.Size
boardSize =
    { x = 3, y = 3 }


text : Dict Int String
text =
    Dict.fromList
        [ ( 1, "Grow seed pods into seeds" )
        ]


sequence : Tutorial.Sequence
sequence =
    [ ( 500, ShowContainer )
    , ( 1500, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 2, 1 ) )
    , ( 1500, SetGrowingPods )
    , ( 800, GrowPods Chrysanthemum )
    , ( 600, ResetGrowingPods )
    , ( 1500, HideCanvas )
    , ( 1500, ExitTutorial )
    ]
