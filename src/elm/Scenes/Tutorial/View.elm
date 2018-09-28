module Scenes.Tutorial.View exposing (fadeLine, handleSkip, leavingStyles, renderLines_, renderResourceBank, renderTiles, resourceBankOffsetX, showIf, tutorialBoard, tutorialView)

import Config.Color exposing (darkYellow, greyYellow)
import Config.Scale as ScaleConfig
import Data.Board.Block exposing (getTileState, hasLine)
import Data.Board.Types exposing (..)
import Data.Tutorial exposing (getText)
import Dict
import Helpers.Css.Format exposing (pc)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (TimingFunction(..))
import Helpers.Css.Transform exposing (..)
import Helpers.Css.Transition exposing (easeAll, transitionStyle)
import Helpers.Html exposing (emptyProperty)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Tutorial.Types exposing (..)
import Views.Level.Layout exposing (renderLineLayer, renderLines)
import Views.Level.Styles exposing (boardHeight, boardWidth)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (scoreIcon)


tutorialView : TutorialModel -> Html TutorialMsg
tutorialView model =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-5"
        , styleAttr (backgroundColor "rgba(255, 252, 227, 0.98)")
        , styleAttr
            (transitionStyle
                { property = "all"
                , duration = 1200
                , timing = Linear
                , delay = Nothing
                }
            )
        , classList <| showIf model.canvasVisible
        ]
        [ div
            [ style "margin-top" (pc -3)
            , styleAttr
                (transitionStyle
                    { property = "all"
                    , duration = 800
                    , timing = Linear
                    , delay = Nothing
                    }
                )
            , classList <| showIf model.containerVisible
            , class "tc"
            ]
            [ tutorialBoard model
            , p
                [ styleAttr (color darkYellow)
                , styleAttr (easeAll 500)
                , classList <| showIf model.textVisible
                ]
                [ text <| getText model.text model.currentText ]
            ]
        , p
            [ handleSkip model
            , styleAttr (color greyYellow)
            , styleAttr (bottomStyle 30)
            , styleAttr
                (transitionStyle
                    { property = "all"
                    , duration = 800
                    , timing = Linear
                    , delay = Just 800
                    }
                )
            , classList <| showIf model.containerVisible
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
    div
        [ class "center relative"
        , classList <| showIf model.boardVisible
        , styleAttr (widthStyle <| boardWidth model)
        , styleAttr (heightStyle <| boardHeight model)
        , styleAttr (easeAll 500)
        ]
        [ div [ class "absolute z-5" ] [ renderResourceBank model ]
        , div [ class "absolute z-2" ] <| renderTiles model
        , div [ class "absolute z-0" ] <| renderLines_ model
        ]


renderResourceBank : TutorialModel -> Html msg
renderResourceBank ({ window, resourceBankVisible, resourceBank } as model) =
    let
        tileScale =
            ScaleConfig.tileScaleFactor window

        offsetX =
            resourceBankOffsetX model

        offsetY =
            -100
    in
    div
        [ styleAttr (easeAll 800)
        , styleAttr (transformStyle [ translate offsetX offsetY ])
        , classList <| showIf resourceBankVisible
        ]
        [ scoreIcon resourceBank <| ScaleConfig.baseTileSizeY * tileScale ]


resourceBankOffsetX : TutorialModel -> Float
resourceBankOffsetX model =
    ScaleConfig.baseTileSizeX
        * toFloat (model.boardDimensions.x - 1)
        * ScaleConfig.tileScaleFactor model.window
        / 2


renderLines_ : TutorialModel -> List (Html msg)
renderLines_ model =
    model.board
        |> Dict.toList
        |> List.map (fadeLine model)


fadeLine : TileConfig model -> Move -> Html msg
fadeLine model (( _, tile ) as move) =
    let
        visible =
            hasLine tile
    in
    div
        [ styleAttr (easeAll 500)
        , classList <| showIf visible
        ]
        [ renderLineLayer model move ]


renderTiles : TutorialModel -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (\mv -> renderTile_ (leavingStyles model mv) model mv)


leavingStyles : TutorialModel -> Move -> List Style
leavingStyles model (( _, block ) as move) =
    let
        tileState =
            getTileState block
    in
    case tileState of
        Leaving _ order ->
            [ transformStyle [ translate (resourceBankOffsetX model) -100 ]
            , transitionStyle
                { property = "all"
                , duration = 500
                , timing = Ease
                , delay = Just <| toFloat <| modBy 5 order * 80
                }
            ]

        _ ->
            []


showIf : Bool -> List ( String, Bool )
showIf visible =
    [ ( "o-100", visible )
    , ( "o-0", not visible )
    ]
