module Data.Moves.Check exposing (..)

import Data.Directions exposing (isAbove, isBelow, isLeft, isRight, validDirection)
import Data.Moves.Type exposing (emptyMove, moveShape, sameTileType)
import Data.Tiles exposing (addBearing, isCurrentMove, isDragging, moveOrder, setStaticToFirstMove, setToDragging)
import Delay
import Dict
import Dict.Extra
import Model exposing (..)
import Time exposing (millisecond)


handleStopMove : Model -> Model
handleStopMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleStartMove : Move -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
    }


triggerMoveIfSquare : Model -> Cmd Msg
triggerMoveIfSquare model =
    if hasSquareTile model.board then
        Delay.after 0 millisecond SquareMove
    else
        Cmd.none


isValidSquare : Move -> Board -> Bool
isValidSquare first board =
    let
        moves =
            currentMoves board |> List.reverse

        second =
            List.head moves |> Maybe.withDefault emptyMove
    in
        allTrue
            [ moveLongEnough moves
            , validDirection first second
            , sameTileType first second
            , draggingOrderDifferent first second
            ]


draggingOrderDifferent : Move -> Move -> Bool
draggingOrderDifferent ( _, t2 ) ( _, t1 ) =
    moveOrder t2 < (moveOrder t1) - 1


hasSquareTile : Board -> Bool
hasSquareTile board =
    board
        |> Dict.filter (\coord tileState -> moveShape ( coord, tileState ) == Just Square)
        |> (\x -> Dict.size x > 0)


isSquare : List Move -> Bool
isSquare moves =
    moves |> List.any (\a -> moveShape a == Just Square)


allTrue : List Bool -> Bool
allTrue =
    List.foldr (&&) True


collisionWithTail : List Move -> Bool
collisionWithTail moveList =
    False


moveLongEnough : List Move -> Bool
moveLongEnough moves =
    (List.length moves) > 3


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


addToMove : Move -> Board -> Board
addToMove next board =
    let
        newBoard =
            addBearings next board
    in
        if isValidMove next board || isValidSquare next board then
            newBoard
        else
            board


addBearings : Move -> Board -> Board
addBearings next board =
    changeBearings next (currentMove board) |> updateMoves board


updateMoves : Board -> ( Move, Move ) -> Board
updateMoves board ( ( c2, t2 ), ( c1, t1 ) ) =
    board
        |> Dict.insert c1 t1
        |> Dict.insert c2 t2


changeBearings : Move -> Move -> ( Move, Move )
changeBearings (( c2, t2 ) as move2) (( c1, t1 ) as move1) =
    let
        newCurrentMove =
            setNewCurrentMove move2 move1
    in
        if isLeft c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Left t1 )
            )
        else if isRight c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Right t1 )
            )
        else if isAbove c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Up t1 )
            )
        else if isBelow c1 c2 then
            ( newCurrentMove
            , ( c1, addBearing Down t1 )
            )
        else
            ( newCurrentMove
            , ( c1, addBearing Head t1 )
            )


startMove : Move -> Board -> Board
startMove ( c1, t1 ) board =
    board |> Dict.update c1 (Maybe.map (\_ -> setStaticToFirstMove t1))


setNewCurrentMove : Move -> Move -> Move
setNewCurrentMove ( c2, t2 ) m1 =
    ( c2, setToDragging (incrementMoveOrder m1) t2 )


isValidMove : Move -> Board -> Bool
isValidMove next board =
    let
        curr =
            currentMove board
    in
        validDirection next curr
            && sameTileType next curr
            && isUniqueMove next board


isUniqueMove : Move -> Board -> Bool
isUniqueMove next board =
    isInCurrentMove next board
        |> not


isInCurrentMove : Move -> Board -> Bool
isInCurrentMove next board =
    board
        |> currentMoves
        |> List.member next


incrementMoveOrder : Move -> Int
incrementMoveOrder ( _, tileState ) =
    (moveOrder tileState) + 1


currentMove : Board -> Move
currentMove board =
    board
        |> Dict.Extra.find isCurrentMove_
        |> Maybe.withDefault emptyMove


coordsList : Board -> List Coord
coordsList board =
    board
        |> Dict.filter isDragging_
        |> Dict.keys


currentMoves : Board -> List Move
currentMoves board =
    board
        |> Dict.filter isDragging_
        |> Dict.toList
        |> List.sortBy moveOrder_


isCurrentMove_ : Coord -> TileState -> Bool
isCurrentMove_ _ =
    isCurrentMove


isDragging_ : Coord -> TileState -> Bool
isDragging_ _ =
    isDragging


moveOrder_ : Move -> Int
moveOrder_ ( _, tileState ) =
    moveOrder tileState
