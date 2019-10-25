module Scenes.Tutorial.Sun exposing (config)

import Board exposing (Board)
import Board.Generate as Board
import Board.Tile exposing (Tile(..))
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial exposing (..)
import Seed exposing (Seed(..))


config : Tutorial.Config
config =
    { text = text
    , boardSize = boardSize
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Sun
    }


initialBoard : Board
initialBoard =
    Board.mono Sun boardSize
        |> Board.addBlock ( 0, 2 ) (Seed Sunflower)
        |> Board.addBlock ( 1, 2 ) (Seed Sunflower)
        |> Board.addBlock ( 2, 2 ) Rain
        |> Board.addBlock ( 2, 0 ) (Seed Sunflower)


boardSize : Board.Size
boardSize =
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
