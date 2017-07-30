module Config.Walls exposing (..)

import Scenes.Level.Model exposing (Coord)


standardWalls : List Coord
standardWalls =
    combineWalls
        [ centerFour
        , leftCenter
        , rightCenter
        ]


corners : List Coord
corners =
    combineWalls
        [ topLeft
        , bottomRight
        ]


combineWalls : List (List Coord) -> List Coord
combineWalls =
    List.concat


centerFour : List Coord
centerFour =
    [ ( 3, 3 )
    , ( 4, 3 )
    , ( 3, 4 )
    , ( 4, 4 )
    ]


topLeft : List Coord
topLeft =
    [ ( 0, 0 )
    , ( 1, 0 )
    , ( 0, 1 )
    ]


bottomRight : List Coord
bottomRight =
    [ ( 7, 7 )
    , ( 6, 7 )
    , ( 7, 6 )
    ]


leftCenter : List Coord
leftCenter =
    [ ( 2, 0 )
    , ( 3, 0 )
    , ( 4, 0 )
    ]


rightCenter : List Coord
rightCenter =
    [ ( 2, 7 )
    , ( 3, 7 )
    , ( 4, 7 )
    ]
