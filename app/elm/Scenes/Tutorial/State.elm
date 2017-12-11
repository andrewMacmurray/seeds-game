module Scenes.Tutorial.State exposing (..)

import Config.Tutorial exposing (..)
import Data.Level.Board.Tile exposing (..)
import Data.Level.Move.Bearing exposing (addBearings)
import Dict
import Helpers.Effect exposing (pause, sequenceMs)
import Scenes.Level.State exposing (handleAddNewTiles, mapBoard, transformBoard)
import Scenes.Level.Types exposing (..)
import Scenes.Tutorial.Types as Tutorial exposing (..)


initialState : Tutorial.Model
initialState =
    { board = tutorialBoard1
    , boardHidden = False
    , textHidden = False
    , seedBankHidden = True
    , containerHidden = True
    , canvasHidden = False
    , moveShape = Just Line
    , tileSize = { y = 51, x = 55 }
    , seedType = Sunflower
    , boardScale = 2
    , text = getText 1
    }


update : Tutorial.Msg -> Tutorial.Model -> ( Tutorial.Model, Cmd Tutorial.Msg )
update msg model =
    case msg of
        StartSequence ->
            model ! [ sequenceMs tutorialSequence ]

        DragTile coord ->
            handleDragTile coord model ! []

        SetGrowingPods ->
            mapBoard setDraggingToGrowing model ! []

        SetLeavingSeeds ->
            mapBoard setToLeaving model ! []

        GrowPods ->
            mapBoard growSeedPod model ! []

        ResetGrowingPods ->
            mapBoard setGrowingToStatic model ! []

        AddNewTiles tiles ->
            handleAddNewTiles tiles model ! []

        ResetLeaving ->
            mapBoard setLeavingToEmpty model ! []

        BoardScale n ->
            { model | boardScale = n } ! []

        HideBoard ->
            { model | boardHidden = True } ! []

        ShowBoard ->
            { model | boardHidden = False } ! []

        HideText ->
            { model | textHidden = True } ! []

        ShowText ->
            { model | textHidden = False } ! []

        HideSeedBank ->
            { model | seedBankHidden = True } ! []

        ShowSeedBank ->
            { model | seedBankHidden = False } ! []

        HideContainer ->
            { model | containerHidden = True } ! []

        ShowContainer ->
            { model | containerHidden = False } ! []

        HideCanvas ->
            { model | canvasHidden = True } ! []

        ResetBoard board ->
            { model | board = board } ! []

        TutorialText n ->
            { model | text = getText n } ! []

        ExitTutorial ->
            -- hub intercepts this message
            model ! []


tutorialSequence : List ( Float, Tutorial.Msg )
tutorialSequence =
    List.concat
        [ appearSequence
        , pause 1200 <| dragSequence1
        , pause 1500 <| growSeedPodsSequence
        , pause 1500 <| nextBoardSequence
        , pause 1500 <| dragSequence2
        ]


appearSequence : List ( Float, Tutorial.Msg )
appearSequence =
    [ ( 0, ShowContainer )
    ]


growSeedPodsSequence : List ( Float, Tutorial.Msg )
growSeedPodsSequence =
    [ ( 0, SetGrowingPods )
    , ( 800, GrowPods )
    , ( 600, ResetGrowingPods )
    ]


nextBoardSequence : List ( Float, Tutorial.Msg )
nextBoardSequence =
    [ ( 0, HideBoard )
    , ( 1000, HideText )
    , ( 500, BoardScale 3 )
    , ( 50, TutorialText 2 )
    , ( 50, ResetBoard tutorialBoard2 )
    , ( 450, ShowBoard )
    , ( 0, ShowText )
    ]


dragSequence2 : List ( Float, Tutorial.Msg )
dragSequence2 =
    [ ( 0, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 2, 1 ) )
    , ( 100, ShowSeedBank )
    , ( 1500, SetLeavingSeeds )
    , ( 1500, ResetLeaving )
    , ( 400, AddNewTiles [ SeedPod, SeedPod, SeedPod, SeedPod ] )
    , ( 2000, HideCanvas )
    , ( 1500, ExitTutorial )
    ]


dragSequence1 : List ( Float, Tutorial.Msg )
dragSequence1 =
    [ ( 0, DragTile ( 0, 0 ) )
    , ( 400, DragTile ( 0, 1 ) )
    , ( 400, DragTile ( 1, 1 ) )
    , ( 400, DragTile ( 1, 0 ) )
    ]


handleDragTile : Coord -> Tutorial.Model -> Tutorial.Model
handleDragTile coord model =
    let
        tile =
            Dict.get coord model.board |> Maybe.withDefault (Space (Static Seed))
    in
        { model | board = addBearings ( coord, tile ) model.board }
