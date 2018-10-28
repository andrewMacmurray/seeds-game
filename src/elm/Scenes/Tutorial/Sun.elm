module Scenes.Tutorial.Sun exposing (config)

import Data.Board.Types exposing (..)
import Data.Tutorial exposing (addBlock, sunBoard)
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial exposing (..)


config : Tutorial.Config
config =
    { text = text
    , boardDimensions = boardDimensions
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Sun
    }


initialBoard : Board
initialBoard =
    sunBoard boardDimensions
        |> addBlock ( 0, 2 ) (Seed Sunflower)
        |> addBlock ( 1, 2 ) (Seed Sunflower)
        |> addBlock ( 2, 2 ) Rain
        |> addBlock ( 2, 0 ) (Seed Sunflower)


boardDimensions : BoardDimensions
boardDimensions =
    { x = 3, y = 3 }


text : Dict Int String
text =
    Dict.fromList
        [ ( 1, "Harvest the sun's warmth for our seeds" )
        ]


sequence : Tutorial.Sequence
sequence =
    [ ( 500, ShowContainer )
    , ( 1500, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 2, 1 ) )
    , ( 100, ShowResourceBank )
    , ( 1500, SetLeaving )
    , ( 500, ResetLeaving )
    , ( 400, EnteringTiles [ Sun, Sun, Sun, Sun ] )
    , ( 2500, HideCanvas )
    , ( 1500, ExitTutorial )
    ]
