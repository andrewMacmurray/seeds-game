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
addToMove current move =
    let
        valid =
            checkMove current move
    in
        if valid then
            move |> Maybe.map ((::) current)
        else
            move


checkMove : ( Coord, Tile ) -> Maybe Move -> Bool
checkMove ( c2, t2 ) move =
    currentMove move
        |> Maybe.map (\( c1, t1 ) -> validDirection c1 c2 && isSameType t1 t2)
        |> Maybe.withDefault False


isSameType : Tile -> Tile -> Bool
isSameType t1 t2 =
    t1 == t2


currentMove : Maybe Move -> Maybe ( Coord, Tile )
currentMove move =
    move |> Maybe.andThen List.head
