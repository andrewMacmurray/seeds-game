module Scenes.Level.State exposing (..)

import Config.Text exposing (getSuccessMessage, randomSuccessMessage)
import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Board.Falling exposing (setFallingTiles)
import Data.Level.Board.Generate exposing (..)
import Data.Level.Board.Shift exposing (shiftBoard)
import Data.Level.Board.Square exposing (setAllTilesOfTypeToDragging)
import Data.Level.Board.Tile exposing (..)
import Data.Level.Move.Check exposing (addToMove, startMove)
import Data.Level.Move.Square exposing (triggerMoveIfSquare)
import Data.Level.Move.Utils exposing (currentMoveTileType)
import Data.Level.Score exposing (addScoreFromMoves, initialScores, levelComplete)
import Delay
import Dict exposing (Dict)
import Helpers.Dict exposing (mapValues)
import Helpers.Effect exposing (sequenceMs, trigger)
import Scenes.Hub.Types as Main exposing (..)
import Scenes.Level.Types as Level exposing (..)
import Time exposing (millisecond)
import Types exposing (InfoWindow(..))


levelInit : LevelData -> Main.Model -> Cmd Main.Msg
levelInit config model =
    Cmd.batch
        [ handleGenerateTiles config model.levelModel
        , randomSuccessMessage GenerateSuccessMessage
        ]
        |> Cmd.map Main.LevelMsg


initialState : Level.Model
initialState =
    { board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , moveShape = Nothing
    , seedType = Sunflower
    , tileSettings = []
    , boardDimensions = { y = 8, x = 8 }
    , scoreIconSize = 32
    , tileSize = { y = 51, x = 55 }
    , topBarHeight = 80
    , levelComplete = False
    , successMessage = getSuccessMessage 0
    , levelInfoWindow = Hidden
    , mouse = { y = 0, x = 0 }
    , window = { height = 0, width = 0 }
    }


update : Level.Msg -> Level.Model -> ( Level.Model, Cmd Level.Msg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            (model
                |> handleMakeBoard tiles
                |> transformBoard (addWalls walls)
            )
                ! []

        StopMove moveShape ->
            case currentMoveTileType model.board of
                Just SeedPod ->
                    model ! [ growSeedPodsSequence ]

                _ ->
                    model ! [ removeTilesSequence moveShape ]

        SetLeavingTiles ->
            (model
                |> handleAddScore
                |> mapBoard setToLeaving
            )
                ! []

        SetFallingTiles ->
            transformBoard setFallingTiles model ! []

        ShiftBoard ->
            (model
                |> transformBoard shiftBoard
                |> mapBoard setFallingToStatic
                |> mapBoard setLeavingToEmpty
            )
                ! []

        SetGrowingSeedPods ->
            mapBoard setDraggingToGrowing model ! []

        GrowPodsToSeeds ->
            model ! [ generateRandomSeedType model.tileSettings ]

        InsertGrowingSeeds seedType ->
            handleInsertNewSeeds seedType model ! []

        ResetGrowingSeeds ->
            mapBoard setGrowingToStatic model ! []

        GenerateEnteringTiles ->
            model ! [ generateEnteringTiles model.tileSettings model.board ]

        GenerateSuccessMessage message ->
            { model | successMessage = message } ! []

        InsertEnteringTiles tiles ->
            handleInsertEnteringTiles tiles model ! []

        ResetEntering ->
            transformBoard (mapValues setEnteringToStatic) model ! []

        ResetMove ->
            handleStopMove model ! []

        StartMove move ->
            handleStartMove move model ! []

        CheckMove move ->
            handleCheckMove move model

        SquareMove ->
            handleSquareMove model ! [ Delay.after 600 millisecond <| StopMove Square ]

        CheckLevelComplete ->
            handleCheckLevelComplete model

        ShowMessage ->
            { model | levelInfoWindow = Visible model.successMessage } ! []

        ExitMessage ->
            { model | levelInfoWindow = Exiting model.successMessage } ! []

        HideMessage ->
            { model | levelInfoWindow = Hidden } ! []

        ExitLevel ->
            -- top level update checks for this message and transitions scene
            model ! []



-- SEQUENCES


growSeedPodsSequence : Cmd Level.Msg
growSeedPodsSequence =
    sequenceMs
        [ ( 0, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : MoveShape -> Cmd Level.Msg
removeTilesSequence moveShape =
    sequenceMs
        [ ( 0, SetLeavingTiles )
        , ( 0, ResetMove )
        , ( fallDelay moveShape, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles )
        , ( 500, ResetEntering )
        ]


fallDelay : MoveShape -> Float
fallDelay moveShape =
    if moveShape == Square then
        500
    else
        350



-- UPDATE HELPERS


handleGenerateTiles : LevelData -> Level.Model -> Cmd Level.Msg
handleGenerateTiles levelData { boardDimensions } =
    generateInitialTiles levelData boardDimensions


handleMakeBoard : List TileType -> BoardConfig model -> BoardConfig model
handleMakeBoard tileList ({ boardDimensions } as model) =
    { model | board = makeBoard boardDimensions tileList }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tileList =
    transformBoard <| insertNewEnteringTiles tileList


handleInsertNewSeeds : SeedType -> HasBoard model -> HasBoard model
handleInsertNewSeeds seedType =
    transformBoard <| insertNewSeeds seedType


handleAddScore : Level.Model -> Level.Model
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


mapBoard : (Block -> Block) -> HasBoard model -> HasBoard model
mapBoard f model =
    { model | board = (mapValues f) model.board }


transformBoard : (a -> a) -> { m | board : a } -> { m | board : a }
transformBoard fn model =
    { model | board = fn model.board }


handleStopMove : Level.Model -> Level.Model
handleStopMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleStartMove : Move -> Level.Model -> Level.Model
handleStartMove move model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
    }


handleCheckMove : Move -> Level.Model -> ( Level.Model, Cmd Level.Msg )
handleCheckMove move model =
    let
        newModel =
            model |> handleCheckMove_ move
    in
        newModel ! [ triggerMoveIfSquare newModel.board ]


handleCheckMove_ : Move -> Level.Model -> Level.Model
handleCheckMove_ move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


handleSquareMove : Level.Model -> Level.Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


handleCheckLevelComplete : Level.Model -> ( Level.Model, Cmd Level.Msg )
handleCheckLevelComplete model =
    if levelComplete model.scores && not model.levelComplete then
        { model | levelComplete = True } ! [ exitSequence ]
    else
        model ! []


exitSequence : Cmd Level.Msg
exitSequence =
    sequenceMs
        [ ( 500, ShowMessage )
        , ( 2000, ExitMessage )
        , ( 1000, HideMessage )
        , ( 0, ExitLevel )
        ]
