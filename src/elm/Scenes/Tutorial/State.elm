module Scenes.Tutorial.State exposing (init, update)

import Browser.Events
import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (setFallingTiles)
import Data.Board.Generate exposing (insertNewEnteringTiles)
import Data.Board.Map exposing (..)
import Data.Board.Move.Bearing exposing (addBearings)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Types exposing (..)
import Data.Level.Types exposing (LevelData)
import Data.Window as Window
import Dict
import Exit exposing (continue, exit)
import Helpers.Delay exposing (pause, sequence, trigger)
import Scenes.Tutorial.Types exposing (..)
import Shared
import Task



-- Init


init : TutorialConfig -> Shared.Data -> ( TutorialModel, Cmd TutorialMsg )
init config shared =
    ( loadTutorialData config <| initialState shared
    , sequence <| pause 500 config.sequence
    )


initialState : Shared.Data -> TutorialModel
initialState shared =
    { shared = shared
    , board = Dict.empty
    , boardVisible = True
    , textVisible = True
    , resourceBankVisible = False
    , containerVisible = False
    , canvasVisible = True
    , skipped = False
    , moveShape = Just Line
    , resourceBank = Seed Sunflower
    , boardDimensions = { y = 2, x = 2 }
    , currentText = 1
    , text = Dict.empty
    }


loadTutorialData : TutorialConfig -> TutorialModel -> TutorialModel
loadTutorialData config model =
    { model
        | boardDimensions = config.boardDimensions
        , board = config.board
        , text = config.text
        , resourceBank = config.resourceBank
        , currentText = 1
        , skipped = False
    }



-- Update


update : TutorialMsg -> TutorialModel -> Exit.Status ( TutorialModel, Cmd TutorialMsg )
update msg model =
    case msg of
        DragTile coord ->
            continue (handleDragTile coord model) []

        SetGrowingPods ->
            continue (mapBlocks setDraggingToGrowing model) []

        SetLeaving ->
            continue (mapBlocks setToLeaving model) []

        ResetLeaving ->
            continue (mapBlocks setLeavingToEmpty model) []

        GrowPods seedType ->
            continue (mapBlocks (growSeedPod seedType) model) []

        ResetGrowingPods ->
            continue (mapBlocks setGrowingToStatic model) []

        EnteringTiles tiles ->
            continue (handleInsertEnteringTiles tiles model) []

        TriggerSquare ->
            continue (handleSquareMove model) []

        FallTiles ->
            continue (mapBoard setFallingTiles model) []

        ShiftBoard ->
            continue
                (model
                    |> mapBoard shiftBoard
                    |> mapBlocks setFallingToStatic
                    |> mapBlocks setLeavingToEmpty
                )
                []

        SetBoardDimensions n ->
            continue { model | boardDimensions = n } []

        HideBoard ->
            continue { model | boardVisible = False } []

        ShowBoard ->
            continue { model | boardVisible = True } []

        HideText ->
            continue { model | textVisible = False } []

        ShowText ->
            continue { model | textVisible = True } []

        HideResourceBank ->
            continue { model | resourceBankVisible = False } []

        ShowResourceBank ->
            continue { model | resourceBankVisible = True } []

        HideContainer ->
            continue { model | containerVisible = False } []

        ShowContainer ->
            continue { model | containerVisible = True } []

        HideCanvas ->
            continue { model | canvasVisible = False } []

        ResetBoard board ->
            continue { model | board = board } []

        NextText ->
            continue { model | currentText = model.currentText + 1 } []

        SkipTutorial ->
            continue model [ skipSequence ]

        DisableTutorial ->
            continue { model | skipped = True } []

        ResetVisibilities ->
            continue (resetVisibilities model) []

        ExitTutorial ->
            exit model [ trigger ResetVisibilities ]



-- Update Helpers


resetVisibilities : TutorialModel -> TutorialModel
resetVisibilities model =
    { model
        | boardVisible = True
        , textVisible = True
        , resourceBankVisible = False
        , containerVisible = False
        , canvasVisible = True
    }


skipSequence : Cmd TutorialMsg
skipSequence =
    sequence
        [ ( 0, HideCanvas )
        , ( 1500, ExitTutorial )
        , ( 0, DisableTutorial )
        ]


handleSquareMove : TutorialModel -> TutorialModel
handleSquareMove model =
    { model | board = setAllTilesOfTypeToDragging model.board }


handleDragTile : Coord -> TutorialModel -> TutorialModel
handleDragTile coord model =
    let
        sunflower =
            Space <| Static <| Seed Sunflower

        tile =
            Dict.get coord model.board |> Maybe.withDefault sunflower
    in
    { model | board = addBearings ( coord, tile ) model.board }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tileList =
    mapBoard <| insertNewEnteringTiles tileList
