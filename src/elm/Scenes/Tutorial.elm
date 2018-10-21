module Scenes.Tutorial exposing
    ( Config
    , Model
    , Msg(..)
    , Sequence
    , init
    , update
    , view
    )

import Browser.Events
import Config.Scale as ScaleConfig
import Css.Color exposing (darkYellow, greyYellow)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (delay, linear, transitionAll)
import Css.Unit exposing (pc)
import Data.Board.Block exposing (..)
import Data.Board.Falling exposing (setFallingTiles)
import Data.Board.Generate exposing (insertNewEnteringTiles)
import Data.Board.Map exposing (..)
import Data.Board.Move.Bearing exposing (addBearings)
import Data.Board.Move.Square exposing (setAllTilesOfTypeToDragging)
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Types exposing (..)
import Data.Tutorial exposing (getText)
import Dict exposing (Dict)
import Data.Exit as Exit exposing (continue, exit)
import Helpers.Delay exposing (pause, sequence, trigger)
import Helpers.Attribute exposing (emptyProperty)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Shared exposing (Window)
import Task
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (boardHeight, boardWidth)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (scoreIcon)



-- MODEL


type alias Model =
    { shared : Shared.Data
    , board : Board
    , boardVisible : Bool
    , textVisible : Bool
    , resourceBankVisible : Bool
    , containerVisible : Bool
    , canvasVisible : Bool
    , skipped : Bool
    , moveShape : Maybe MoveShape
    , resourceBank : TileType
    , boardDimensions : BoardDimensions
    , currentText : Int
    , text : Dict Int String
    }


type alias Config =
    { text : Dict Int String
    , boardDimensions : BoardDimensions
    , board : Board
    , resourceBank : TileType
    , sequence : Sequence
    }


type alias Sequence =
    List ( Float, Msg )


type Msg
    = DragTile Coord
    | SetGrowingPods
    | SetLeaving
    | ResetLeaving
    | GrowPods SeedType
    | ResetGrowingPods
    | EnteringTiles (List TileType)
    | TriggerSquare
    | FallTiles
    | ShiftBoard
    | SetBoardDimensions BoardDimensions
    | HideBoard
    | ShowBoard
    | HideText
    | ShowText
    | HideResourceBank
    | ShowResourceBank
    | HideContainer
    | ShowContainer
    | HideCanvas
    | ResetBoard Board
    | NextText
    | SkipTutorial
    | DisableTutorial
    | ExitTutorial



-- INIT


init : Config -> Shared.Data -> ( Model, Cmd Msg )
init config shared =
    ( loadTutorialData config <| initialState shared
    , sequence <| pause 500 config.sequence
    )


initialState : Shared.Data -> Model
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



-- UPDATE


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
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

        ExitTutorial ->
            exit model []



-- UPDATE Helpers


skipSequence : Cmd Msg
skipSequence =
    sequence
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


handleInsertEnteringTiles : List TileType -> Model -> Model
handleInsertEnteringTiles tileList =
    mapBoard <| insertNewEnteringTiles tileList



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-5"
        , style
            [ backgroundColor "rgba(255, 252, 227, 0.98)"
            , transitionAll 1200 [ linear ]
            ]
        , showIf model.canvasVisible
        ]
        [ div
            [ style
                [ Style.property "margin-top" (pc -3)
                , transitionAll 800 [ linear ]
                ]
            , showIf model.containerVisible
            , class "tc"
            ]
            [ tutorialBoard model
            , p
                [ style
                    [ color darkYellow
                    , transitionAll 500 []
                    ]
                , showIf model.textVisible
                ]
                [ text <| getText model.text model.currentText ]
            ]
        , p
            [ handleSkip model
            , style
                [ color greyYellow
                , bottom 30
                , transitionAll 800 [ linear, delay 800 ]
                ]
            , showIf model.containerVisible
            , class "absolute left-0 right-0 pointer tc ttu tracked-mega f6"
            ]
            [ text "skip" ]
        ]


handleSkip : Model -> Attribute Msg
handleSkip model =
    if not model.skipped then
        onClick SkipTutorial

    else
        emptyProperty


tutorialBoard : Model -> Html msg
tutorialBoard model =
    let
        vm =
            ( model.shared.window, model.boardDimensions )
    in
    div
        [ class "center relative"
        , showIf model.boardVisible
        , style
            [ width <| toFloat <| boardWidth vm
            , height <| toFloat <| boardHeight vm
            , transitionAll 500 []
            ]
        ]
        [ div [ class "absolute z-5" ] [ renderResourceBank model ]
        , div [ class "absolute z-2" ] <| renderTiles model
        , div [ class "absolute z-0" ] <| renderLines_ model
        ]


renderResourceBank : Model -> Html msg
renderResourceBank ({ shared, resourceBankVisible, resourceBank } as model) =
    let
        window =
            shared.window

        tileScale =
            ScaleConfig.tileScaleFactor window

        offsetX =
            resourceBankOffsetX model

        offsetY =
            -100
    in
    div
        [ style
            [ transitionAll 800 []
            , transform [ translate offsetX offsetY ]
            ]
        , showIf resourceBankVisible
        ]
        [ scoreIcon resourceBank <| ScaleConfig.baseTileSizeY * tileScale ]


resourceBankOffsetX : Model -> Float
resourceBankOffsetX model =
    ScaleConfig.baseTileSizeX
        * toFloat (model.boardDimensions.x - 1)
        * ScaleConfig.tileScaleFactor model.shared.window
        / 2


renderLines_ : Model -> List (Html msg)
renderLines_ model =
    model.board
        |> Dict.toList
        |> List.map (fadeLine model)


fadeLine : Model -> Move -> Html msg
fadeLine model (( _, tile ) as move) =
    let
        visible =
            hasLine tile
    in
    div
        [ style [ transitionAll 500 [] ]
        , showIf visible
        ]
        [ renderLine model.shared.window move ]


renderTiles : Model -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (\mv -> renderTile_ (leavingStyles model mv) model.shared.window model.moveShape mv)


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, block ) as move) =
    case getTileState block of
        Leaving _ order ->
            [ transform [ translate (resourceBankOffsetX model) -100 ]
            , transitionAll 500 [ delay <| modBy 5 order * 80 ]
            ]

        _ ->
            []
