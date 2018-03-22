module Config.Wall exposing (..)

import Config.Color exposing (blockYellow)
import Data.Board.Types exposing (Coord, WallColor)
import Data.Board.Wall exposing (toCoords, withColor)


yellowWalls : List Coord -> List ( WallColor, Coord )
yellowWalls =
    withColor blockYellow


centerColumns : List Coord
centerColumns =
    toCoords
        [ [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        ]


standardWalls : List Coord
standardWalls =
    toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, w, w, s, s, w ]
        , [ w, s, s, w, w, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


corners : List Coord
corners =
    toCoords
        [ [ w, w, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, w, w ]
        ]


innerBorders : List Coord
innerBorders =
    toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


borders : List Coord
borders =
    toCoords
        [ [ w, w, s, w, w, s, w, w ]
        , [ w, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, w ]
        , [ w, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, w ]
        , [ w, w, s, w, w, s, w, w ]
        ]


w : Bool
w =
    True


s : Bool
s =
    False
