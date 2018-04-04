module Scenes.Tutorial.State exposing (..)

import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (setFallingTiles)
import Data.Board.Map exposing (..)
import Data.Board.Move.Bearing exposing (addBearings)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Types exposing (..)
import Data.Level.Types exposing (LevelData)
import Dict
import Helpers.Delay exposing (pause, sequenceMs, trigger)
import Helpers.OutMsg exposing (noOutMsg, withOutMsg)
import Scenes.Level.State as Level exposing (handleInsertEnteringTiles)
import Scenes.Level.Types exposing (LevelModel)
import Scenes.Tutorial.Types exposing (..)
import Task
import Window exposing (resizes, size)


-- Init


init : LevelData TutorialConfig -> TutorialConfig -> ( TutorialModel, Cmd TutorialMsg )
init levelData config =
    let
        ( levelModel, levelCmd ) =
            Level.init levelData
    in
        loadTutorialData config (initialState levelModel)
            ! [ Task.perform WindowSize size
              , Cmd.map LevelMsg levelCmd
              , sequenceMs <| pause 500 config.sequence
              ]


initialState : LevelModel -> TutorialModel
initialState levelModel =
    { board = Dict.empty
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
    , window = { height = 0, width = 0 }
    , levelModel = levelModel
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


update : TutorialMsg -> TutorialModel -> ( TutorialModel, Cmd TutorialMsg, Maybe TutorialOutMsg )
update msg model =
    case msg of
        LevelMsg levelMsg ->
            let
                ( levelModel, levelCmd, _ ) =
                    Level.update levelMsg model.levelModel
            in
                noOutMsg { model | levelModel = levelModel } [ Cmd.map LevelMsg levelCmd ]

        DragTile coord ->
            noOutMsg (handleDragTile coord model) []

        SetGrowingPods ->
            noOutMsg (mapBlocks setDraggingToGrowing model) []

        SetLeaving ->
            noOutMsg (mapBlocks setToLeaving model) []

        ResetLeaving ->
            noOutMsg (mapBlocks setLeavingToEmpty model) []

        GrowPods seedType ->
            noOutMsg (mapBlocks (growSeedPod seedType) model) []

        ResetGrowingPods ->
            noOutMsg (mapBlocks setGrowingToStatic model) []

        EnteringTiles tiles ->
            noOutMsg (handleInsertEnteringTiles tiles model) []

        TriggerSquare ->
            noOutMsg (handleSquareMove model) []

        FallTiles ->
            noOutMsg (mapBoard setFallingTiles model) []

        ShiftBoard ->
            noOutMsg
                (model
                    |> mapBoard shiftBoard
                    |> mapBlocks setFallingToStatic
                    |> mapBlocks setLeavingToEmpty
                )
                []

        SetBoardDimensions n ->
            noOutMsg { model | boardDimensions = n } []

        HideBoard ->
            noOutMsg { model | boardVisible = False } []

        ShowBoard ->
            noOutMsg { model | boardVisible = True } []

        HideText ->
            noOutMsg { model | textVisible = False } []

        ShowText ->
            noOutMsg { model | textVisible = True } []

        HideResourceBank ->
            noOutMsg { model | resourceBankVisible = False } []

        ShowResourceBank ->
            noOutMsg { model | resourceBankVisible = True } []

        HideContainer ->
            noOutMsg { model | containerVisible = False } []

        ShowContainer ->
            noOutMsg { model | containerVisible = True } []

        HideCanvas ->
            noOutMsg { model | canvasVisible = False } []

        ResetBoard board ->
            noOutMsg { model | board = board } []

        NextText ->
            noOutMsg { model | currentText = model.currentText + 1 } []

        SkipTutorial ->
            noOutMsg model [ skipSequence ]

        DisableTutorial ->
            noOutMsg { model | skipped = True } []

        ResetVisibilities ->
            noOutMsg (resetVisibilities model) []

        ExitTutorial ->
            withOutMsg model [ trigger ResetVisibilities ] ExitToLevel

        WindowSize size ->
            noOutMsg { model | window = size } []



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
    sequenceMs
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


subscriptions : TutorialModel -> Sub TutorialMsg
subscriptions model =
    Sub.batch
        [ resizes WindowSize
        , Level.subscriptions model.levelModel |> Sub.map LevelMsg
        ]
