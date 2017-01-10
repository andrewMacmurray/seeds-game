module Directions exposing (..)

import Types exposing (..)


sameValue : Tile -> Tile -> Bool
sameValue t1 t2 =
    t1.value == t2.value


isLeft : Coord -> Coord -> Bool
isLeft ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 - 1 && y2 == y1


isRight : Coord -> Coord -> Bool
isRight ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 + 1 && y2 == y1


isAbove : Coord -> Coord -> Bool
isAbove ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 && y2 == y1 - 1


isBelow : Coord -> Coord -> Bool
isBelow ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 && y2 == y1 + 1


isLeftAndAbove : Coord -> Coord -> Bool
isLeftAndAbove ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 - 1 && y2 == y1 - 1


isRightAndAbove : Coord -> Coord -> Bool
isRightAndAbove ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 + 1 && y2 == y1 - 1


isLeftAndBelow : Coord -> Coord -> Bool
isLeftAndBelow ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 - 1 && y2 == y1 + 1


isRightAndBelow : Coord -> Coord -> Bool
isRightAndBelow ( x1, y1 ) ( x2, y2 ) =
    x2 == x1 + 1 && y2 == y1 + 1


anyTrue : List Bool -> Bool
anyTrue =
    List.foldl (||) False


directionsToCheck : List (Coord -> Coord -> Bool)
directionsToCheck =
    [ isLeft
    , isRight
    , isAbove
    , isBelow
    , isLeftAndAbove
    , isRightAndAbove
    , isLeftAndBelow
    , isRightAndBelow
    ]


check : a -> a -> (a -> a -> Bool) -> Bool
check a b fn =
    fn a b


validDirection : Coord -> Coord -> Bool
validDirection c2 c1 =
    List.map (check c2 c1) directionsToCheck
        |> anyTrue


checkCurrentMove : Tile -> Move -> Bool
checkCurrentMove tile currentMove =
    case currentMove of
        Full moves ->
            let
                allButLast2 =
                    List.take ((List.length moves) - 2) moves
            in
                List.member tile allButLast2
                    |> not

        _ ->
            True


validMove : Model -> Tile -> Bool
validMove { currentMove, currentTile } t2 =
    let
        checkAll t2 t1 currentMove =
            sameValue t2 t1
                && validDirection t2.coord t1.coord
                && checkCurrentMove t2 currentMove
    in
        case currentMove of
            Empty ->
                True

            OneTile t1 ->
                checkAll t2 t1 currentMove

            Pair ( _, t1 ) ->
                checkAll t2 t1 currentMove

            Full tiles ->
                case currentTile of
                    Just t1 ->
                        checkAll t2 t1 currentMove

                    Nothing ->
                        False
