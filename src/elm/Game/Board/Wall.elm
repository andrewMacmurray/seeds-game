module Game.Board.Wall exposing
    ( Config
    , addToBoard
    , coords
    , corners
    , fromCoords
    , invisible
    , s
    , w
    )

import Element exposing (Color)
import Element.Palette as Palette
import Game.Board as Board exposing (Board)
import Game.Board.Block exposing (Block(..))
import Game.Board.Coord exposing (Coord)



-- Walls


type Config
    = Config Color Coord



-- Construct


fromCoords : List Coord -> List Config
fromCoords =
    withColor Palette.blockYellow


invisible : List Coord -> List Config
invisible =
    withColor Palette.transparent


addToBoard : List Config -> Board -> Board
addToBoard walls_ board =
    List.foldl addWall board walls_


addWall : Config -> Board -> Board
addWall (Config color coord) =
    Board.placeAt coord (Wall color)


withColor : Color -> List Coord -> List Config
withColor color =
    List.map (Config color)



-- Visually construct Coordinates


corners : List Config
corners =
    [ [ w, w, s, s, s, s, s, s ]
    , [ w, s, s, s, s, s, s, s ]
    , [ s, s, s, s, s, s, s, s ]
    , [ s, s, s, s, s, s, s, s ]
    , [ s, s, s, s, s, s, s, s ]
    , [ s, s, s, s, s, s, s, s ]
    , [ s, s, s, s, s, s, s, w ]
    , [ s, s, s, s, s, s, w, w ]
    ]
        |> coords
        |> fromCoords


w : Bool
w =
    True


s : Bool
s =
    False


coords : List (List Bool) -> List Coord
coords allWalls =
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
