module Scenes.Level.Update exposing (..)

import Data.Level.Board.Block exposing (addWalls)
import Data.Level.Board.Entering exposing (addNewTiles, makeNewTiles)
import Data.Level.Board.Falling exposing (setFallingTiles)
import Data.Level.Board.Make exposing (generateTiles, makeBoard)
import Data.Level.Score exposing (addScoreFromMoves, initialScores)
import Data.Level.Board.Shift exposing (shiftBoard)
import Data.Level.Board.Square exposing (setAllTilesOfTypeToDragging)
import Data.Level.Board.Tile exposing (growSeedPod, setDraggingToGrowing, setEnteringToStatic, setFallingToStatic, setGrowingToStatic, setLeavingToEmpty, setToLeaving)
import Data.Level.Move.Check exposing (addToMove, startMove)
import Data.Level.Move.Square exposing (triggerMoveIfSquare)
import Data.Level.Move.Type exposing (currentMoveTileType)
import Delay
import Dict exposing (Dict)
import Helpers.Delay exposing (sequenceMs)
import Helpers.Dict exposing (mapValues)
import Html exposing (Html, div)
import Model as Main
import Data.Hub.Types exposing (..)
import Scenes.Level.Model exposing (..)
import Data.Level.Types exposing (..)
import Time exposing (millisecond)
import Views.Level.Board exposing (board, handleStop)
import Views.Level.LineDrag exposing (handleLineDrag)
import Views.Level.TopBar exposing (topBar)


-- VIEW


levelView : Main.Model -> Html Msg
levelView model =
    div [ handleStop model.levelModel ]
        [ topBar model.levelModel
        , board model
        , handleLineDrag model
        ]



-- STATE


initCmd : LevelData -> Main.Model -> Cmd Main.Msg
initCmd config model =
    handleGenerateTiles config model.levelModel
        |> Cmd.map Main.LevelMsg


initialState : Model
initialState =
    { board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , moveShape = Nothing
    , seedType = Sunflower
    , tileProbabilities = []
    , boardScale = 8
    , scoreIconSize = 32
    , tileSize = { y = 51, x = 55 }
    , topBarHeight = 80
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            (model
                |> handleMakeBoard tiles
                |> transformBoard (addWalls walls)
            )
                ! []

        AddTiles tiles ->
            (model |> handleAddNewTiles tiles) ! []

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
            (model |> transformBoard setFallingTiles) ! []

        ShiftBoard ->
            (model
                |> transformBoard shiftBoard
                |> mapBoard setFallingToStatic
                |> mapBoard setLeavingToEmpty
            )
                ! []

        SetGrowingSeedPods ->
            (model |> mapBoard setDraggingToGrowing) ! []

        GrowPodsToSeeds ->
            (model |> mapBoard growSeedPod) ! []

        ResetGrowingSeeds ->
            (model |> mapBoard setGrowingToStatic) ! []

        MakeNewTiles ->
            model ! [ makeNewTiles model.tileProbabilities model.board AddTiles ]

        ResetEntering ->
            (model |> transformBoard (mapValues setEnteringToStatic)) ! []

        ResetMove ->
            (model |> handleStopMove) ! []

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            handleCheckMove move model

        SquareMove ->
            (model |> handleSquareMove) ! [ Delay.after 600 millisecond <| StopMove Square ]



-- SEQUENCES


growSeedPodsSequence : Cmd Msg
growSeedPodsSequence =
    sequenceMs
        [ ( 0, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : MoveShape -> Cmd Msg
removeTilesSequence moveShape =
    sequenceMs
        [ ( 0, SetLeavingTiles )
        , ( 0, ResetMove )
        , ( fallDelay moveShape, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, MakeNewTiles )
        , ( 500, ResetEntering )
        ]


fallDelay : MoveShape -> Float
fallDelay moveShape =
    if moveShape == Square then
        500
    else
        350



-- UPDATE HELPERS


handleGenerateTiles : LevelData -> Model -> Cmd Msg
handleGenerateTiles levelData { boardScale } =
    generateTiles levelData boardScale InitTiles


handleMakeBoard : List TileType -> Model -> Model
handleMakeBoard tileList ({ boardScale } as model) =
    { model | board = makeBoard boardScale tileList }


handleAddNewTiles : List TileType -> Model -> Model
handleAddNewTiles tileList =
    transformBoard <| addNewTiles tileList


handleAddScore : Model -> Model
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


mapBoard : (Block -> Block) -> Model -> Model
mapBoard f model =
    { model | board = (mapValues f) model.board }


transformBoard : (a -> a) -> { m | board : a } -> { m | board : a }
transformBoard fn model =
    { model | board = fn model.board }


handleStopMove : Model -> Model
handleStopMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleStartMove : Move -> Model -> Model
handleStartMove move model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
    }


handleCheckMove : Move -> Model -> ( Model, Cmd Msg )
handleCheckMove move model =
    let
        newModel =
            model |> handleCheckMove_ move
    in
        newModel ! [ triggerMoveIfSquare newModel.board SquareMove ]


handleCheckMove_ : Move -> Model -> Model
handleCheckMove_ move model =
    if model.isDragging then
        { model | board = addToMove move model.board }
    else
        model


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }
