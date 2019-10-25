module Scenes.Tutorial.Seed exposing (config)

import Board
import Board.Generate as Board
import Board.Tile exposing (SeedType(..), Type(..))
import Dict exposing (Dict)
import Scenes.Tutorial as Tutorial exposing (..)


config : Tutorial.Config
config =
    { text = text
    , boardSize = boardSize
    , board = Board.mono (Seed Sunflower) boardSize
    , sequence = sequence
    , resourceBank = Seed Sunflower
    }


boardSize : Board.Size
boardSize =
    { x = 2, y = 2 }


text : Dict Int String
text =
    Dict.fromList
        [ ( 1, "Connect seeds to fill the seed bank" ) ]


sequence : Tutorial.Sequence
sequence =
    [ ( 500, ShowContainer )
    , ( 1500, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 1, 0 ) )
    , ( 100, ShowResourceBank )
    , ( 1500, SetLeaving )
    , ( 500, ResetLeaving )
    , ( 400
      , EnteringTiles
            [ Seed Sunflower
            , Seed Sunflower
            , Seed Sunflower
            , Seed Sunflower
            ]
      )
    , ( 2000, HideCanvas )
    , ( 1500, ExitTutorial )
    ]
