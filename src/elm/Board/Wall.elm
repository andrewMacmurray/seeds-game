module Board.Wall exposing
    ( Config
    , addToBoard
    , corners
    , invisible
    , s
    , toCoords
    , w
    , walls
    )

import Board exposing (Board)
import Board.Block exposing (Block(..))
import Board.Coord exposing (Coord)
import Element exposing (Color)
import Element.Palette as Palette



-- Walls


type Config
    = Config Color Coord



-- Construct


walls : List Coord -> List Config
walls =
    withColor Palette.blockYellow


invisible : List Coord -> List Config
invisible =
    withColor Palette.transparent


addToBoard : List Config -> Board -> Board
addToBoard walls_ board =
    List.foldl addWall board walls_


addWall : Config -> Board -> Board
addWall (Config color coord) =
    Board.placeAt coord <| Wall color


withColor : Color -> List Coord -> List Config
withColor color =
    List.map (Config color)



-- Visually construct Coordinates


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
