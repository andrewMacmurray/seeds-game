module Scenes.Tutorial.State exposing (..)

import Data.Level.Board.Falling exposing (setFallingTiles)
import Data.Level.Board.Shift exposing (shiftBoard)
import Data.Level.Board.Square exposing (setAllTilesOfTypeToDragging)
import Data.Level.Board.Tile exposing (..)
import Data.Level.Move.Bearing exposing (addBearings)
import Dict
import Helpers.Effect exposing (pause, sequenceMs)
import Scenes.Level.State exposing (handleInsertEnteringTiles, mapBoard, transformBoard)
import Scenes.Level.Types exposing (Block(..), Coord, MoveShape(..), SeedType(..), TileState(..), TileType(..))
import Scenes.Tutorial.Types exposing (..)


initialState : Model
initialState =
    { board = Dict.empty
    , boardVisible = True
    , textVisible = True
    , resourceBankVisible = False
    , containerVisible = False
    , canvasVisible = True
    , skipped = False
    , moveShape = Just Line
    , tileSize = { y = 51, x = 55 }
    , resourceBank = Seed Sunflower
    , boardDimensions = { y = 2, x = 2 }
    , topBarHeight = 0
    , currentText = 1
    , text = Dict.empty
    , window = { height = 0, width = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
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

        GrowPods seedType ->
            mapBoard (growSeedPod seedType) model ! []

        ResetGrowingPods ->
            mapBoard setGrowingToStatic model ! []

        EnteringTiles tiles ->
            handleInsertEnteringTiles tiles model ! []

        TriggerSquare ->
            handleSquareMove model ! []

        FallTiles ->
            transformBoard setFallingTiles model ! []

        ShiftBoard ->
            (model
                |> transformBoard shiftBoard
                |> mapBoard setFallingToStatic
                |> mapBoard setLeavingToEmpty
            )
                ! []

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

        SkipTutorial ->
            model ! [ skipSequence ]

        DisableTutorial ->
            { model | skipped = True } ! []

        ResetVisibilities ->
            resetVisibilities model ! []

        ExitTutorial ->
            -- hub intercepts this message
            model ! []


handleInit : InitConfig -> Model -> Model
handleInit config model =
    { model
        | boardDimensions = config.boardDimensions
        , board = config.board
        , text = config.text
        , resourceBank = config.resourceBank
        , currentText = 1
        , skipped = False
    }


resetVisibilities : Model -> Model
resetVisibilities model =
    { model
        | boardVisible = True
        , textVisible = True
        , resourceBankVisible = False
        , containerVisible = False
        , canvasVisible = True
    }


skipSequence : Cmd Msg
skipSequence =
    sequenceMs
        [ ( 0, HideCanvas )
        , ( 1500, ExitTutorial )
        , ( 0, DisableTutorial )
        ]


handleSquareMove : Model -> Model
handleSquareMove model =
    { model | board = setAllTilesOfTypeToDragging model.board }


handleDragTile : Coord -> Model -> Model
handleDragTile coord model =
    let
        sunflower =
            Seed Sunflower |> Static |> Space

        tile =
            Dict.get coord model.board |> Maybe.withDefault sunflower
    in
        { model | board = addBearings ( coord, tile ) model.board }
