module Scenes.Tutorial.State exposing (..)

import Data.Level.Board.Tile exposing (..)
import Data.Level.Move.Bearing exposing (addBearings)
import Dict
import Helpers.Effect exposing (pause, sequenceMs)
import Scenes.Level.State exposing (handleInsertEnteringTiles, mapBoard, transformBoard)
import Scenes.Level.Types exposing (..)
import Scenes.Tutorial.Types as Tutorial exposing (..)


initialState : Tutorial.Model
initialState =
    { board = Dict.empty
    , boardVisible = True
    , textVisible = True
    , resourceBankVisible = False
    , containerVisible = False
    , canvasVisible = True
    , moveShape = Just Line
    , tileSize = { y = 51, x = 55 }
    , resourceBank = Seed Sunflower
    , boardDimensions = { y = 2, x = 2 }
    , topBarHeight = 0
    , currentText = 1
    , text = Dict.empty
    , window = { height = 0, width = 0 }
    }


update : Tutorial.Msg -> Tutorial.Model -> ( Tutorial.Model, Cmd Tutorial.Msg )
update msg model =
    case msg of
        StartSequence config ->
            handleInit config model ! [ sequenceMs config.sequence ]

        DragTile coord ->
            handleDragTile coord model ! []

        SetGrowingPods ->
            mapBoard setDraggingToGrowing model ! []

        SetLeaving ->
            mapBoard setToLeaving model ! []

        ResetLeaving ->
            mapBoard setLeavingToEmpty model ! []

        GrowPods ->
            mapBoard (growSeedPod Sunflower) model ! []

        ResetGrowingPods ->
            mapBoard setGrowingToStatic model ! []

        EnteringTiles tiles ->
            handleInsertEnteringTiles tiles model ! []

        SetBoardDimensions n ->
            { model | boardDimensions = n } ! []

        HideBoard ->
            { model | boardVisible = False } ! []

        ShowBoard ->
            { model | boardVisible = True } ! []

        HideText ->
            { model | textVisible = False } ! []

        ShowText ->
            { model | textVisible = True } ! []

        HideResourceBank ->
            { model | resourceBankVisible = False } ! []

        ShowResourceBank ->
            { model | resourceBankVisible = True } ! []

        HideContainer ->
            { model | containerVisible = False } ! []

        ShowContainer ->
            { model | containerVisible = True } ! []

        HideCanvas ->
            { model | canvasVisible = False } ! []

        ResetBoard board ->
            { model | board = board } ! []

        NextText ->
            { model | currentText = model.currentText + 1 } ! []

        ExitTutorial ->
            -- hub intercepts this message
            resetVisibilities model ! []


handleInit : InitConfig -> Tutorial.Model -> Tutorial.Model
handleInit config model =
    { model
        | boardDimensions = config.boardDimensions
        , board = config.board
        , text = config.text
        , resourceBank = config.resourceBank
        , currentText = 1
    }


resetVisibilities : Tutorial.Model -> Tutorial.Model
resetVisibilities model =
    { model
        | boardVisible = True
        , textVisible = True
        , resourceBankVisible = False
        , containerVisible = False
        , canvasVisible = True
    }


handleDragTile : Coord -> Tutorial.Model -> Tutorial.Model
handleDragTile coord model =
    let
        sunflower =
            Seed Sunflower |> Static |> Space

        tile =
            Dict.get coord model.board |> Maybe.withDefault sunflower
    in
        { model | board = addBearings ( coord, tile ) model.board }
