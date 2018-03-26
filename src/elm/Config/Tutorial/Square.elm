module Config.Tutorial.Square exposing (..)

import Data.Tutorial exposing (addBlock, seedBoard)
import Data.Board.Types exposing (..)
import Dict exposing (Dict)
import Scenes.Tutorial.Types as Tutorial exposing (..)


config : TutorialConfig
config =
    { text = text
    , boardDimensions = boardDimensions
    , board = initialBoard
    , sequence = sequence
    , resourceBank = Seed Sunflower
    }


initialBoard : Board
initialBoard =
    seedBoard boardDimensions
        |> addBlock ( 3, 3 ) Rain
        |> addBlock ( 3, 2 ) Rain
        |> addBlock ( 1, 3 ) Rain


boardDimensions : BoardDimensions
boardDimensions =
    { x = 4, y = 4 }


text : Dict Int String
text =
    Dict.fromList
        [ ( 1, "Make squares to remove all tiles of that type" )
        , ( 2, "If in doubt, just make squares!" )
        ]


sequence : Tutorial.Sequence
sequence =
    [ ( 500, ShowContainer )
    , ( 1500, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 1, 0 ) )
    , ( 400, DragTile ( 0, 0 ) )
    , ( 0, TriggerSquare )
    , ( 100, ShowResourceBank )
    , ( 800, SetLeaving )
    , ( 500, FallTiles )
    , ( 500, ShiftBoard )
    , ( 400, EnteringTiles enteringTiles )
    , ( 1000, HideText )
    , ( 500, NextText )
    , ( 500, ShowText )
    , ( 2000, HideCanvas )
    , ( 1500, ExitTutorial )
    ]


enteringTiles : List TileType
enteringTiles =
    let
        seed =
            Seed Sunflower
    in
        [ Rain
        , seed
        , seed
        , Rain
        , seed
        , Rain
        , seed
        , seed
        , Rain
        , Rain
        , seed
        , seed
        , Rain
        ]
