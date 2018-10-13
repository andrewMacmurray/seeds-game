module Scenes.Tutorial.View exposing
    ( fadeLine
    , handleSkip
    , leavingStyles
    , renderLines_
    , renderResourceBank
    , renderTiles
    , resourceBankOffsetX
    , tutorialBoard
    , tutorialView
    )

import Config.Scale as ScaleConfig
import Css.Color exposing (darkYellow, greyYellow)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (delay, linear, transitionAll)
import Css.Unit exposing (pc)
import Data.Board.Block exposing (getTileState, hasLine)
import Data.Board.Types exposing (..)
import Data.Tutorial exposing (getText)
import Dict
import Helpers.Html exposing (emptyProperty)
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Scenes.Tutorial.Types exposing (..)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (boardHeight, boardWidth)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (scoreIcon)


tutorialView : TutorialModel -> Html TutorialMsg
tutorialView model =
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


handleSkip : TutorialModel -> Attribute TutorialMsg
handleSkip model =
    if not model.skipped then
        onClick SkipTutorial

    else
        emptyProperty


tutorialBoard : TutorialModel -> Html msg
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


renderResourceBank : TutorialModel -> Html msg
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


resourceBankOffsetX : TutorialModel -> Float
resourceBankOffsetX model =
    ScaleConfig.baseTileSizeX
        * toFloat (model.boardDimensions.x - 1)
        * ScaleConfig.tileScaleFactor model.shared.window
        / 2


renderLines_ : TutorialModel -> List (Html msg)
renderLines_ model =
    model.board
        |> Dict.toList
        |> List.map (fadeLine model)


fadeLine : TutorialModel -> Move -> Html msg
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


renderTiles : TutorialModel -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (\mv -> renderTile_ (leavingStyles model mv) model.shared.window model.moveShape mv)


leavingStyles : TutorialModel -> Move -> List Style
leavingStyles model (( _, block ) as move) =
    case getTileState block of
        Leaving _ order ->
            [ transform [ translate (resourceBankOffsetX model) -100 ]
            , transitionAll 500 [ delay <| modBy 5 order * 80 ]
            ]

        _ ->
            []
