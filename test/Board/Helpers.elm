module Board.Helpers exposing (..)

import Model exposing (..)
import Dict


expectedShiftedBoard : Board
expectedShiftedBoard =
    makeDummyBoard shiftedTileList


shiftedTileList : List (List Tile)
shiftedTileList =
    [ [ Blank, Blank, Blank, SeedPod ]
    , [ SeedPod, SeedPod, SeedPod, SeedPod ]
    , [ SeedPod, SeedPod, Sun, Sun ]
    , [ SeedPod, Rain, SeedPod, SeedPod ]
    ]


dummyValidMove1 : List Move
dummyValidMove1 =
    let
        validCoords =
            [ ( 3, 0 ), ( 3, 1 ), ( 3, 2 ) ]
    in
        validCoords
            |> List.map (\coord -> Dict.get coord dummyBoard)
            |> List.map (Maybe.withDefault Blank)
            |> List.map2 (,) validCoords


boardAfterMove1 : Board
boardAfterMove1 =
    dummyBoard
        |> Dict.insert ( 3, 0 ) Blank
        |> Dict.insert ( 3, 1 ) Blank
        |> Dict.insert ( 3, 2 ) Blank


dummyBoard : Board
dummyBoard =
    makeDummyBoard dummyTileList


makeDummyBoard : List (List Tile) -> Board
makeDummyBoard tileList =
    tileList
        |> List.indexedMap (\y row -> List.indexedMap (\x tile -> ( ( y, x ), tile )) row)
        |> List.concat
        |> Dict.fromList


dummyTileList : List (List Tile)
dummyTileList =
    [ [ SeedPod, SeedPod, SeedPod, SeedPod ]
    , [ SeedPod, SeedPod, Sun, SeedPod ]
    , [ SeedPod, Rain, SeedPod, SeedPod, Sun ]
    , [ SeedPod, SeedPod, SeedPod, SeedPod ]
    ]
