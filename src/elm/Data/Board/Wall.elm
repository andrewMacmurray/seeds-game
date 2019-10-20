module Data.Board.Wall exposing
    ( Config
    , addToBoard
    , corners
    , invisible
    , s
    , toCoords
    , w
    , walls
    , withColor
    )

import Css.Color as Color exposing (Color)
import Data.Board as Board
import Data.Board.Block exposing (Block(..))
import Data.Board.Types exposing (Board, Coord)



-- Construct Walls


type Config
    = Config ( Color, Coord )


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


invisible : List Coord -> List Config
invisible =
    withColor Color.lightYellow


walls : List Coord -> List Config
walls =
    withColor Color.blockYellow


addToBoard : List Config -> Board -> Board
addToBoard walls_ board =
    List.foldl addWall board walls_


addWall : Config -> Board -> Board
addWall (Config ( wallColor, coord )) =
    Board.placeAt coord <| Wall wallColor


withColor : Color -> List Coord -> List Config
withColor color =
    List.map (\coord -> Config ( color, coord ))
