module Scenes.Level exposing
    ( Model
    , Msg
    , Status(..)
    , getShared
    , init
    , menuOptions
    , update
    , updateShared
    , view
    )

import Browser.Events
import Css.Color as Color exposing (Color)
import Css.Style as Style exposing (..)
import Css.Transform exposing (scale, translate)
import Css.Transition exposing (delay, transitionAll)
import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (..)
import Data.Board.Generate exposing (..)
import Data.Board.Map exposing (..)
import Data.Board.Move.Check exposing (addMoveToBoard, startMove)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging, triggerMoveIfSquare)
import Data.Board.Moves exposing (currentMoveTileType)
import Data.Board.Score as Score exposing (addScoreFromMoves, initialScores, levelComplete, scoreTileTypes)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Data.Board.Wall exposing (addWalls)
import Data.InfoWindow as InfoWindow exposing (InfoWindow)
import Data.Level.Types exposing (TileSetting)
import Data.Levels as Levels
import Data.Pointer exposing (Pointer, onPointerDown, onPointerMove, onPointerUp)
import Data.Window exposing (Window)
import Dict exposing (Dict)
import Exit exposing (continue, exitWith)
import Helpers.Attribute as Attribute
import Helpers.Delay exposing (sequence, trigger)
import Helpers.Dict exposing (indexedDictFrom)
import Html exposing (Attribute, Html, div, p, span, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Shared
import Task
import Views.InfoWindow
import Views.Level.Line exposing (renderLine)
import Views.Level.LineDrag exposing (LineViewModel, handleLineDrag)
import Views.Level.Styles exposing (..)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (TopBarViewModel, remainingMoves, topBar)
import Views.Menu as Menu



-- MODEL


type alias Model =
    { shared : Shared.Data
    , board : Board
    , scores : Scores
    , isDragging : Bool
    , remainingMoves : Int
    , moveShape : Maybe MoveShape
    , tileSettings : List TileSetting
    , boardDimensions : BoardDimensions
    , levelStatus : Status
    , infoWindow : InfoWindow InfoContent
    , pointer : Pointer
    }


type Msg
    = InitTiles (List ( Color, Coord )) (List TileType)
    | SquareMove
    | StopMove
    | StartMove Move Pointer
    | CheckMove Pointer
    | SetLeavingTiles
    | SetFallingTiles
    | SetGrowingSeedPods
    | GrowPodsToSeeds
    | InsertGrowingSeeds SeedType
    | ResetGrowingSeeds
    | GenerateEnteringTiles
    | InsertEnteringTiles (List TileType)
    | ResetEntering
    | ShiftBoard
    | ResetMove
    | CheckLevelComplete
    | ShowInfo InfoContent
    | HideInfo
    | InfoLeaving
    | InfoHidden
    | PromptRestart
    | PromptExit
    | LevelWon
    | LevelLost
    | RestartLevel
    | RestartLevelLoseLife
    | ExitLevel
    | ExitLevelLoseLife


type Status
    = NotStarted
    | InProgress
    | Lose
    | Win
    | Restart
    | Exit


type InfoContent
    = Success
    | NoMovesLeft
    | RestartAreYouSure
    | ExitAreYouSure



-- Shared


getShared : Model -> Shared.Data
getShared model =
    model.shared


updateShared : (Shared.Data -> Shared.Data) -> Model -> Model
updateShared f model =
    { model | shared = f model.shared }


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option PromptRestart "Restart"
    , Menu.option PromptExit "Exit"
    ]



-- Init


init : Levels.LevelConfig -> Shared.Data -> ( Model, Cmd Msg )
init config shared =
    let
        model =
            shared
                |> initialState
                |> addLevelData config
    in
    ( model
    , handleGenerateTiles config model
    )


addLevelData : Levels.LevelConfig -> Model -> Model
addLevelData { tiles, walls, boardDimensions, moves } model =
    { model
        | scores = initialScores tiles
        , board = addWalls walls model.board
        , boardDimensions = boardDimensions
        , tileSettings = tiles
        , remainingMoves = moves
    }


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , board = Dict.empty
    , scores = Dict.empty
    , isDragging = False
    , remainingMoves = 10
    , moveShape = Nothing
    , tileSettings = []
    , boardDimensions = { y = 8, x = 8 }
    , levelStatus = NotStarted
    , infoWindow = InfoWindow.hidden
    , pointer = { y = 0, x = 0 }
    }



-- Update


update : Msg -> Model -> Exit.With Status ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles walls tiles ->
            continue
                (model
                    |> handleMakeBoard tiles
                    |> mapBoard (addWalls walls)
                )
                []

        StopMove ->
            case currentMoveTileType model.board of
                Just SeedPod ->
                    continue model [ growSeedPodsSequence model.moveShape ]

                _ ->
                    continue model [ removeTilesSequence model.moveShape ]

        SetLeavingTiles ->
            continue
                (model
                    |> handleAddScore
                    |> mapBlocks setToLeaving
                )
                []

        SetFallingTiles ->
            continue (mapBoard setFallingTiles model) []

        ShiftBoard ->
            continue
                (model
                    |> mapBoard shiftBoard
                    |> mapBlocks setFallingToStatic
                    |> mapBlocks setLeavingToEmpty
                )
                []

        SetGrowingSeedPods ->
            continue (mapBlocks setDraggingToGrowing model) []

        GrowPodsToSeeds ->
            continue model [ generateRandomSeedType InsertGrowingSeeds model.tileSettings ]

        InsertGrowingSeeds seedType ->
            continue (handleInsertNewSeeds seedType model) []

        ResetGrowingSeeds ->
            continue (mapBlocks setGrowingToStatic model) []

        GenerateEnteringTiles ->
            continue model [ generateEnteringTiles InsertEnteringTiles model.tileSettings model.board ]

        InsertEnteringTiles tiles ->
            continue (handleInsertEnteringTiles tiles model) []

        ResetEntering ->
            continue (mapBlocks setEnteringToStatic model) []

        ResetMove ->
            continue
                (model
                    |> handleResetMove
                    |> handleDecrementRemainingMoves
                )
                []

        StartMove move pointer ->
            continue (handleStartMove move pointer model) []

        CheckMove pointer ->
            checkMoveFromPosition pointer model

        SquareMove ->
            continue (handleSquareMove model) []

        CheckLevelComplete ->
            handleCheckLevelComplete model

        HideInfo ->
            continue model [ hideInfoSequence ]

        ShowInfo info ->
            continue { model | infoWindow = InfoWindow.visible info } []

        InfoLeaving ->
            continue { model | infoWindow = InfoWindow.leaving model.infoWindow } []

        InfoHidden ->
            continue { model | infoWindow = InfoWindow.hidden } []

        PromptRestart ->
            continue model [ handleRestartPrompt model ]

        PromptExit ->
            continue model [ handleExitPrompt model ]

        LevelWon ->
            exitWith Win model

        LevelLost ->
            exitWith Lose model

        RestartLevel ->
            exitWith Restart model

        RestartLevelLoseLife ->
            exitWith Restart <| updateShared Shared.decrementLife model

        ExitLevel ->
            exitWith Exit model

        ExitLevelLoseLife ->
            exitWith Exit <| updateShared Shared.decrementLife model



-- Sequences


growSeedPodsSequence : Maybe MoveShape -> Cmd Msg
growSeedPodsSequence moveShape =
    sequence
        [ ( initialDelay moveShape, SetGrowingSeedPods )
        , ( 0, ResetMove )
        , ( 800, GrowPodsToSeeds )
        , ( 0, CheckLevelComplete )
        , ( 600, ResetGrowingSeeds )
        ]


removeTilesSequence : Maybe MoveShape -> Cmd Msg
removeTilesSequence moveShape =
    sequence
        [ ( initialDelay moveShape, SetLeavingTiles )
        , ( 0, ResetMove )
        , ( fallDelay moveShape, SetFallingTiles )
        , ( 500, ShiftBoard )
        , ( 0, CheckLevelComplete )
        , ( 0, GenerateEnteringTiles )
        , ( 500, ResetEntering )
        ]


winSequence : Model -> Cmd Msg
winSequence model =
    sequence
        [ ( 500, ShowInfo Success )
        , ( 2000, HideInfo )
        , ( 1000, LevelWon )
        ]


loseSequence : Cmd Msg
loseSequence =
    sequence
        [ ( 500, ShowInfo NoMovesLeft )
        , ( 2000, HideInfo )
        , ( 1000, LevelLost )
        ]


hideInfoSequence : Cmd Msg
hideInfoSequence =
    sequence
        [ ( 0, InfoLeaving )
        , ( 1000, InfoHidden )
        ]


initialDelay : Maybe MoveShape -> Float
initialDelay moveShape =
    if moveShape == Just Square then
        200

    else
        0


fallDelay : Maybe MoveShape -> Float
fallDelay moveShape =
    if moveShape == Just Square then
        500

    else
        350



-- Update Helpers


type alias HasBoard model =
    { model | board : Board, boardDimensions : BoardDimensions }


handleGenerateTiles : Levels.LevelConfig -> Model -> Cmd Msg
handleGenerateTiles config { boardDimensions } =
    generateInitialTiles (InitTiles config.walls) config.tiles boardDimensions


handleMakeBoard : List TileType -> HasBoard model -> HasBoard model
handleMakeBoard tileList ({ boardDimensions } as model) =
    { model | board = makeBoard boardDimensions tileList }


handleInsertEnteringTiles : List TileType -> HasBoard model -> HasBoard model
handleInsertEnteringTiles tileList =
    mapBoard <| insertNewEnteringTiles tileList


handleInsertNewSeeds : SeedType -> HasBoard model -> HasBoard model
handleInsertNewSeeds seedType =
    mapBoard <| insertNewSeeds seedType


handleAddScore : Model -> Model
handleAddScore model =
    { model | scores = addScoreFromMoves model.board model.scores }


handleResetMove : Model -> Model
handleResetMove model =
    { model
        | isDragging = False
        , moveShape = Nothing
    }


handleDecrementRemainingMoves : Model -> Model
handleDecrementRemainingMoves model =
    if model.remainingMoves < 1 then
        { model | remainingMoves = 0 }

    else
        { model | remainingMoves = model.remainingMoves - 1 }


handleStartMove : Move -> Pointer -> Model -> Model
handleStartMove move pointer model =
    { model
        | isDragging = True
        , board = startMove move model.board
        , moveShape = Just Line
        , pointer = pointer
    }


checkMoveFromPosition : Pointer -> Model -> Exit.With Status ( Model, Cmd Msg )
checkMoveFromPosition pointer model =
    case moveFromPosition pointer model of
        Just move ->
            checkMoveWithSquareTrigger move { model | pointer = pointer }

        Nothing ->
            continue { model | pointer = pointer } []


checkMoveWithSquareTrigger : Move -> Model -> Exit.With Status ( Model, Cmd Msg )
checkMoveWithSquareTrigger move model =
    let
        newModel =
            model |> handleCheckMove move
    in
    continue newModel [ triggerMoveIfSquare SquareMove newModel.board ]


handleCheckMove : Move -> Model -> Model
handleCheckMove move model =
    if model.isDragging then
        { model | board = addMoveToBoard move model.board }

    else
        model


moveFromPosition : Pointer -> Model -> Maybe Move
moveFromPosition pointer model =
    moveFromCoord model.board <| coordsFromPosition pointer model


moveFromCoord : Board -> Coord -> Maybe Move
moveFromCoord board coord =
    board |> Dict.get coord |> Maybe.map (\b -> ( coord, b ))


coordsFromPosition : Pointer -> Model -> Coord
coordsFromPosition pointer model =
    let
        vm =
            ( model.shared.window, model.boardDimensions )

        positionY =
            toFloat <| pointer.y - boardOffsetTop vm

        positionX =
            toFloat <| pointer.x - boardOffsetLeft vm

        scaleFactorY =
            Tile.scale model.shared.window * Tile.baseSizeY

        scaleFactorX =
            Tile.scale model.shared.window * Tile.baseSizeX
    in
    ( floor <| positionY / scaleFactorY
    , floor <| positionX / scaleFactorX
    )


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | moveShape = Just Square
        , board = setAllTilesOfTypeToDragging model.board
    }


handleCheckLevelComplete : Model -> Exit.With Status ( Model, Cmd Msg )
handleCheckLevelComplete model =
    let
        disableMenu =
            updateShared Shared.disableMenu
    in
    if hasWon model then
        continue (disableMenu { model | levelStatus = Win }) [ winSequence model ]

    else if hasLost model then
        continue (disableMenu { model | levelStatus = Lose }) [ loseSequence ]

    else
        continue { model | levelStatus = InProgress } []


hasLost : Model -> Bool
hasLost { remainingMoves, levelStatus } =
    remainingMoves < 1 && levelStatus == InProgress


hasWon : Model -> Bool
hasWon { scores, levelStatus } =
    levelComplete scores && levelStatus == InProgress


handleExitPrompt : Model -> Cmd Msg
handleExitPrompt model =
    if model.levelStatus == NotStarted then
        trigger ExitLevel

    else
        trigger <| ShowInfo ExitAreYouSure


handleRestartPrompt : Model -> Cmd Msg
handleRestartPrompt model =
    if model.levelStatus == NotStarted then
        trigger RestartLevel

    else
        trigger <| ShowInfo RestartAreYouSure



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ handleStop model
        , handleCheck model
        , disableIfComplete model
        ]
        [ topBar <| topBarViewModel model
        , renderInfoWindow model
        , renderBoard model
        , handleLineDrag <| lineViewModel model
        , moveCaptureArea
        ]


handleStop : Model -> Attribute Msg
handleStop model =
    applyIf model.isDragging <| onPointerUp StopMove


handleCheck : Model -> Attribute Msg
handleCheck model =
    applyIf model.isDragging <| onPointerMove CheckMove


disableIfComplete : Model -> Attribute msg
disableIfComplete model =
    applyIf (not <| model.levelStatus == InProgress || model.levelStatus == NotStarted) <| class "touch-disabled"


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf predicate attr =
    if predicate then
        attr

    else
        Attribute.empty


moveCaptureArea : Html msg
moveCaptureArea =
    div [ class "w-100 h-100 fixed z-1 top-0" ] []


renderBoard : Model -> Html Msg
renderBoard model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : Model -> List (Html Msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


renderTile : Model -> Move -> Html Msg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ hanldeMoveEvents model move
        , class "pointer"
        , attribute "touch-action" "none"
        ]
        [ renderTile_ (leavingStyles model move) model.shared.window model.moveShape move ]


renderLines : Model -> List (Html msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLine model.shared.window)


boardLayout : Model -> List (Html msg) -> Html msg
boardLayout model =
    div
        [ style
            [ width <| toFloat <| boardWidth <| tileViewModel model
            , boardMarginTop <| tileViewModel model
            ]
        , class "relative z-3 center flex flex-wrap"
        ]


hanldeMoveEvents : Model -> Move -> Attribute Msg
hanldeMoveEvents model move =
    applyIf (not model.isDragging) <| onPointerDown <| StartMove move


renderInfoWindow : Model -> Html Msg
renderInfoWindow { infoWindow, shared } =
    InfoWindow.content infoWindow
        |> Maybe.map (renderInfoContent shared.successMessageIndex)
        |> Maybe.map (infoContainer infoWindow)
        |> Maybe.withDefault (span [] [])


infoContainer : InfoWindow InfoContent -> Html Msg -> Html Msg
infoContainer infoWindow rendered =
    case InfoWindow.content infoWindow of
        Just RestartAreYouSure ->
            div [ onClick HideInfo ] [ Views.InfoWindow.infoContainer infoWindow rendered ]

        Just ExitAreYouSure ->
            div [ onClick HideInfo ] [ Views.InfoWindow.infoContainer infoWindow rendered ]

        _ ->
            Views.InfoWindow.infoContainer infoWindow rendered


renderInfoContent : Int -> InfoContent -> Html Msg
renderInfoContent successMessageIndex infoContent =
    case infoContent of
        Success ->
            div [ class "pv5 f3 tracked-mega" ] [ text <| successMessage successMessageIndex ]

        NoMovesLeft ->
            div [ class "pv5 f3 tracked-mega" ] [ text "No more moves!" ]

        RestartAreYouSure ->
            areYouSure "Restart" RestartLevelLoseLife

        ExitAreYouSure ->
            areYouSure "Exit" ExitLevelLoseLife


successMessage : Int -> String
successMessage i =
    let
        ii =
            modBy (Dict.size successMessages) i
    in
    Dict.get ii successMessages |> Maybe.withDefault "Amazing!"


successMessages : Dict Int String
successMessages =
    indexedDictFrom 0
        [ "Level Complete!"
        , "Success!"
        , "Win!"
        ]


areYouSure : String -> Msg -> Html Msg
areYouSure yesText msg =
    div [ class "pv4" ]
        [ p [ class "f3 ma0 tracked" ] [ text "Are you sure?" ]
        , p [ class "f7 tracked", style [ marginTop 15, marginBottom 35 ] ] [ text "You will lose a life" ]
        , yesNoButton yesText msg
        ]


yesNoButton : String -> Msg -> Html Msg
yesNoButton yesText msg =
    div []
        [ div
            [ class "dib ttu tracked-mega f7"
            , onClick HideInfo
            , style
                [ color Color.white
                , backgroundColor Color.firrGreen
                , paddingLeft 25
                , paddingRight 15
                , paddingTop 10
                , paddingBottom 10
                , leftPill
                ]
            ]
            [ text "X" ]
        , div
            [ class "dib ttu tracked-mega f7"
            , onClick msg
            , style
                [ color Color.white
                , backgroundColor Color.gold
                , paddingLeft 15
                , paddingRight 20
                , paddingTop 10
                , paddingBottom 10
                , rightPill
                ]
            ]
            [ text yesText ]
        ]


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionAll 800 [ delay <| modBy 5 (leavingOrder tile) * 80 ]
        , opacity 0.2
        , handleExitDirection move model
        ]

    else
        []


handleExitDirection : Move -> Model -> Style
handleExitDirection ( coord, block ) model =
    case getTileState block of
        Leaving Rain _ ->
            getLeavingStyle Rain model

        Leaving Sun _ ->
            getLeavingStyle Sun model

        Leaving (Seed seedType) _ ->
            getLeavingStyle (Seed seedType) model

        _ ->
            Style.empty


getLeavingStyle : TileType -> Model -> Style
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (Tile.hash tileType)
        |> Maybe.withDefault Style.empty


newLeavingStyles : Model -> Dict.Dict String Style
newLeavingStyles model =
    model.tileSettings
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : Model -> Int -> TileType -> ( String, Style )
prepareLeavingStyle model resourceBankIndex tileType =
    ( Tile.hash tileType
    , transform
        [ translate (exitXDistance resourceBankIndex model) -(exitYdistance (tileViewModel model))
        , scale 0.5
        ]
    )


exitXDistance : Int -> Model -> Float
exitXDistance resourceBankIndex model =
    let
        scoreWidth =
            scoreIconSize * 2

        scoreBarWidth =
            model.tileSettings
                |> List.filter Score.collectable
                |> List.length
                |> (*) scoreWidth

        baseOffset =
            (boardWidth (tileViewModel model) - scoreBarWidth) // 2

        offset =
            exitOffsetFunction <| Tile.scale model.shared.window
    in
    toFloat (baseOffset + resourceBankIndex * scoreWidth) + offset


exitOffsetFunction : Float -> Float
exitOffsetFunction x =
    25 * (x ^ 2) - (75 * x) + Tile.baseSizeX


exitYdistance : TileViewModel -> Float
exitYdistance model =
    toFloat (boardOffsetTop model) - 9



-- VIEW MODELS


tileViewModel : Model -> TileViewModel
tileViewModel model =
    ( model.shared.window
    , model.boardDimensions
    )


topBarViewModel : Model -> TopBarViewModel
topBarViewModel model =
    { window = model.shared.window
    , tileSettings = model.tileSettings
    , scores = model.scores
    , remainingMoves = model.remainingMoves
    }


lineViewModel : Model -> LineViewModel
lineViewModel model =
    { window = model.shared.window
    , board = model.board
    , boardDimensions = model.boardDimensions
    , isDragging = model.isDragging
    , pointer = model.pointer
    }
