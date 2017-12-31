module Config.Wall exposing (..)

import Scenes.Level.Types exposing (..)


centerColumns : List Coord
centerColumns =
    combineWalls
        [ column 3
        , column 4
        ]


moreWalls : List Coord
moreWalls =
    combineWalls
        [ standardWalls
        , topCenter
        , bottomCenter
        ]


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


bottomCenter : List Coord
bottomCenter =
    [ ( 7, 3 )
    , ( 7, 4 )
    ]


topCenter : List Coord
topCenter =
    [ ( 0, 3 )
    , ( 0, 4 )
    ]


leftCenter : List Coord
leftCenter =
    [ ( 3, 0 )
    , ( 4, 0 )
    ]


rightCenter : List Coord
rightCenter =
    [ ( 3, 7 )
    , ( 4, 7 )
    ]


withColor : WallColor -> List Coord -> List ( WallColor, Coord )
withColor color =
    List.map ((,) color)


combineWalls : List (List Coord) -> List Coord
combineWalls =
    List.concat


column : Int -> List Coord
column y =
    List.range 0 7 |> List.map (\x -> ( x, y ))
