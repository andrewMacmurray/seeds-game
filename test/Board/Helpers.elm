module Board.Helpers exposing (..)

import Dict
import Model exposing (..)


boardAfter : Board
boardAfter =
    [ tileRow1 |> addCoords 0
    , tileRow2 |> addCoords 1
    , shiftedTileRow3 |> addCoords 2
    ]
        |> List.concat
        |> Dict.fromList


boardBefore : Board
boardBefore =
    [ tileRow1 |> addCoords 0
    , tileRow2 |> addCoords 1
    , tileRow3 |> addCoords 2
    ]
        |> List.concat
        |> Dict.fromList


tileRow1 : List TileState
tileRow1 =
    [ Static SeedPod
    , Static SeedPod
    , Static SeedPod
    ]


tileRow2 : List TileState
tileRow2 =
    [ Static SeedPod
    , Static Sun
    , Static SeedPod
    ]


shiftedTileRow3 : List TileState
shiftedTileRow3 =
    [ Leaving Sun 0
    , Leaving Sun 1
    , Static Rain
    ]


tileRow3 : List TileState
tileRow3 =
    [ Static Rain
    , Leaving Sun 0
    , Leaving Sun 1
    ]


addCoords : Int -> List TileState -> List Move
addCoords rowIndex tiles =
    tiles |> List.indexedMap (addCoord rowIndex)


addCoord : Int -> Int -> TileState -> Move
addCoord x y tile =
    ( ( y, x ), tile )
