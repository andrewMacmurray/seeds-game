module Data.Board.Wall exposing
    ( addWalls
    , toCoords
    , withColor
    )

import Data.Board.Types exposing (Block(..), Board, Coord, WallColor)
import Dict


addWalls : List ( WallColor, Coord ) -> Board -> Board
addWalls coords board =
    List.foldl addWall_ board coords


addWall_ : ( WallColor, Coord ) -> Board -> Board
addWall_ ( wallColor, coord ) currentBoard =
    Dict.update coord (Maybe.map (always <| Wall wallColor)) currentBoard


withColor : WallColor -> List Coord -> List ( WallColor, Coord )
withColor color =
    List.map (\b -> ( color, b ))


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
