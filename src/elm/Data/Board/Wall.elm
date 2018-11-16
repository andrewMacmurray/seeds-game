module Data.Board.Wall exposing
    ( addWalls
    , borders
    , centerColumns
    , corners
    , innerBorders
    , s
    , standardWalls
    , toCoords
    , w
    , withColor
    , yellowWalls
    )

import Css.Color as Color exposing (Color)
import Data.Board.Types exposing (Block(..), Board, Coord)
import Dict



-- Visually Construct wall coordinates


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


toCoords : List (List Bool) -> List Coord
toCoords allWalls =
    allWalls
        |> List.indexedMap (\i r -> List.indexedMap (toCoord i) r)
        |> List.concat
        |> List.concat


toCoord : Int -> Int -> Bool -> List Coord
toCoord i j x =
    if x then
        [ ( i, j ) ]

    else
        []



-- Add Walls to board


addWalls : List ( Color, Coord ) -> Board -> Board
addWalls coords board =
    List.foldl addWall_ board coords


addWall_ : ( Color, Coord ) -> Board -> Board
addWall_ ( wallColor, coord ) currentBoard =
    Dict.update coord (Maybe.map (always <| Wall wallColor)) currentBoard



-- Construct Walls


yellowWalls : List Coord -> List ( Color, Coord )
yellowWalls =
    withColor Color.blockYellow


withColor : Color -> List Coord -> List ( Color, Coord )
withColor color =
    List.map (\b -> ( color, b ))
