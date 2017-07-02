module Data.Moves.Check exposing (..)

import Data.Directions exposing (isAbove, isBelow, isLeft, isRight, validDirection)
import Data.Moves.Square exposing (isValidSquare)
import Data.Moves.Type exposing (emptyMove, sameTileType)
import Data.Tiles exposing (addBearing, isCurrentMove, isDragging, moveOrder, setStaticToDragging, setStaticToFirstMove)
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
    if isValidSquare (currentMoves model.board) then
        Delay.after 0 millisecond SquareMove
    else
        Cmd.none


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


addToMove : Move -> Board -> Board
addToMove next board =
    if isValidMove next board then
        addBearings next board
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
        else
            ( newCurrentMove
            , ( c1, addBearing Down t1 )
            )


startMove : Move -> Board -> Board
startMove ( c1, t1 ) board =
    board |> Dict.update c1 (Maybe.map (\_ -> setStaticToFirstMove t1))


setNewCurrentMove : Move -> Move -> Move
setNewCurrentMove ( c2, t2 ) m1 =
    ( c2, setStaticToDragging (incrementMoveOrder m1) t2 )


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
