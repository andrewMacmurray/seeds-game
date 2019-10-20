module Scenes.Tutorial.Rain exposing (config)

import Data.Board.Generate as Board
import Data.Board.Tile exposing (SeedType(..), Type(..))
import Data.Board.Types exposing (..)
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial exposing (..)


config : Tutorial.Config
config =
    { text = text
    , boardDimensions = dimensions
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Rain
    }


initialBoard : Board
initialBoard =
    Board.mono Rain dimensions
        |> Board.addBlock ( 0, 2 ) (Seed Sunflower)
        |> Board.addBlock ( 1, 2 ) (Seed Sunflower)
        |> Board.addBlock ( 2, 2 ) (Seed Sunflower)
        |> Board.addBlock ( 2, 0 ) (Seed Sunflower)


dimensions : BoardDimensions
dimensions =
    { x = 3, y = 3 }


text : Dict Int String
text =
    Dict.fromList
        [ ( 1, "Collect rain water for our seeds" )
        , ( 2, "Collect all resources to complete the level" )
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
    , ( 400, EnteringTiles [ Rain, Rain, Rain, Rain ] )
    , ( 1000, HideText )
    , ( 500, NextText )
    , ( 500, ShowText )
    , ( 2500, HideCanvas )
    , ( 1500, ExitTutorial )
    ]
