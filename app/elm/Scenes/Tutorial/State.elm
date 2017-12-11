module Scenes.Tutorial.State exposing (..)

import Config.Tutorial exposing (tutorialBoard1)
import Data.Level.Board.Tile exposing (growSeedPod, setDraggingToGrowing, setDraggingToReleasing, setGrowingToStatic, setReleasingToStatic)
import Data.Level.Move.Bearing exposing (addBearings)
import Dict
import Helpers.Effect exposing (sequenceMs)
import Scenes.Level.State exposing (mapBoard)
import Scenes.Level.Types exposing (..)
import Scenes.Tutorial.Types as Tutorial exposing (..)


initialState : Tutorial.Model
initialState =
    { board = tutorialBoard1
    , boardHidden = False
    , moveShape = Just Line
    , tileSize = { y = 51, x = 55 }
    , seedType = Sunflower
    , boardScale = 2
    }


update : Tutorial.Msg -> Tutorial.Model -> ( Tutorial.Model, Cmd Tutorial.Msg )
update msg model =
    case msg of
        DragTile coord order ->
            (model |> handleDragTile coord order) ! []

        GrowSeedPodsSequence ->
            model
                ! [ sequenceMs
                        [ ( 0, SetGrowingPods )
                        , ( 800, GrowPods )
                        , ( 600, ResetGrowingPods )
                        , ( 1000, HideBoard )
                        , ( 500, ResetBoard )
                        , ( 50, ShowBoard )
                        ]
                  ]

        SetGrowingPods ->
            (model |> mapBoard setDraggingToGrowing) ! []

        GrowPods ->
            (model |> mapBoard growSeedPod) ! []

        ResetGrowingPods ->
            (model |> mapBoard setGrowingToStatic) ! []

        DragSequence ->
            model
                ! [ sequenceMs
                        [ ( 0, DragTile ( 0, 0 ) 0 )
                        , ( 400, DragTile ( 0, 1 ) 0 )
                        , ( 400, DragTile ( 1, 1 ) 0 )
                        , ( 400, DragTile ( 1, 0 ) 0 )
                        , ( 1500, GrowSeedPodsSequence )
                        ]
                  ]

        ShowBoard ->
            { model | boardHidden = False } ! []

        HideBoard ->
            { model | boardHidden = True } ! []

        ResetBoard ->
            { model | board = tutorialBoard1 } ! []


handleDragTile : Coord -> Int -> Tutorial.Model -> Tutorial.Model
handleDragTile coord order model =
    let
        tile =
            Dict.get coord model.board |> Maybe.withDefault (Space (Static Seed))
    in
        { model | board = addBearings ( coord, tile ) model.board }
