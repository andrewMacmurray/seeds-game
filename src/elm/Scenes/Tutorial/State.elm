module Scenes.Tutorial.State exposing (..)

import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (setFallingTiles)
import Data.Board.Map exposing (..)
import Data.Board.Move.Bearing exposing (addBearings)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Types exposing (..)
import Dict
import Helpers.Delay exposing (pause, sequenceMs, trigger)
import Helpers.OutMsg exposing (noOutMsg, withOutMsg)
import Scenes.Level.State exposing (handleInsertEnteringTiles)
import Scenes.Tutorial.Types exposing (..)
import Task
import Window exposing (resizes, size)


-- Init


init : Config -> ( Model, Cmd Msg )
init config =
    loadTutorialData config initialState
        ! [ sequenceMs config.sequence
          , getWindowSize
          ]


getWindowSize : Cmd Msg
getWindowSize =
    Task.perform WindowSize size


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
    , resourceBank = Seed Sunflower
    , boardDimensions = { y = 2, x = 2 }
    , currentText = 1
    , text = Dict.empty
    , window = { height = 0, width = 0 }
    }


loadTutorialData : Config -> Model -> Model
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


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
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
            withOutMsg model [ trigger ResetVisibilities ] ExitTutorialToLevel

        WindowSize size ->
            noOutMsg { model | window = size } []



-- Update Helpers


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
            Space <| Static <| Seed Sunflower

        tile =
            Dict.get coord model.board |> Maybe.withDefault sunflower
    in
        { model | board = addBearings ( coord, tile ) model.board }


subscriptions : Model -> Sub Msg
subscriptions _ =
    resizes WindowSize
