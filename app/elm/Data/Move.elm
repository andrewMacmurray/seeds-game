module Data.Move exposing (..)

import Data.Directions exposing (validDirection)
import Model exposing (..)


handleStopMove : Model -> Model
handleStopMove model =
    { model
        | isDragging = False
        , currentMove = Nothing
    }


handleStartMove : ( Coord, Tile ) -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , currentMove = Just [ move ]
    }


handleCheckMove : ( Coord, Tile ) -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | currentMove = addToMove move model.currentMove }
    else
        model


addToMove : ( Coord, Tile ) -> Maybe Move -> Maybe Move
addToMove next move =
    let
        valid =
            checkMove next move
    in
        if valid then
            move |> Maybe.map (\xs -> next :: xs)
        else
            move


checkMove : ( Coord, Tile ) -> Maybe Move -> Bool
checkMove (( c2, t2 ) as next) move =
    currentMove move
        |> Maybe.map (checkDirectionAndType next)
        |> Maybe.map ((&&) (isUniqueMove next move))
        |> Maybe.withDefault False


checkDirectionAndType : ( Coord, Tile ) -> ( Coord, Tile ) -> Bool
checkDirectionAndType ( c2, t2 ) ( c1, t1 ) =
    validDirection c1 c2 && t1 == t2


isUniqueMove : ( Coord, Tile ) -> Maybe Move -> Bool
isUniqueMove next move =
    isInCurrentMove next move
        |> not


isInCurrentMove : ( Coord, Tile ) -> Maybe Move -> Bool
isInCurrentMove next move =
    move
        |> Maybe.map (List.member next)
        |> Maybe.withDefault False


currentMove : Maybe Move -> Maybe ( Coord, Tile )
currentMove move =
    move |> Maybe.andThen List.head
