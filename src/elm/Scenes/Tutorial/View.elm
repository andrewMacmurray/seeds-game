module Scenes.Tutorial.View exposing (..)

import Config.Color exposing (darkYellow, greyYellow)
import Config.Scale as ScaleConfig
import Data.Level.Tutorial exposing (getText)
import Data.Board.Block exposing (getTileState, hasLine)
import Data.Board exposing (Move)
import Data.Board.TileState exposing (TileState(..))
import Dict
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Level.Types exposing (TileConfig)
import Scenes.Tutorial.Types exposing (..)
import Views.Level.Layout exposing (renderLineLayer, renderLines)
import Views.Level.Styles exposing (boardHeight, boardWidth)
import Views.Level.Tile exposing (renderTile_)
import Views.Level.TopBar exposing (scoreIcon)


tutorialView : Model -> Html Msg
tutorialView model =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-5"
        , style
            [ backgroundColor "rgba(255, 252, 227, 0.98)"
            , transitionStyle "1.2s linear"
            ]
        , classList <| showIf model.canvasVisible
        ]
        [ div
            [ style [ ( "margin-top", pc -3 ), transitionStyle "0.8s linear" ]
            , classList <| showIf model.containerVisible
            , class "tc"
            ]
            [ tutorialBoard model
            , p
                [ style [ color darkYellow, transitionStyle "0.5s ease" ]
                , classList <| showIf model.textVisible
                ]
                [ text <| getText model.text model.currentText ]
            ]
        , p
            [ onClick SkipTutorial
            , style
                [ color greyYellow
                , bottomStyle 30
                , transitionStyle "0.8s linear"
                , transitionDelayStyle 800
                ]
            , classList <| showIf model.containerVisible
            , class "absolute left-0 right-0 pointer tc ttu tracked-mega f6"
            ]
            [ text "skip" ]
        ]


tutorialBoard : Model -> Html msg
tutorialBoard model =
    div
        [ class "center relative"
        , classList <| showIf model.boardVisible
        , style
            [ widthStyle <| boardWidth model
            , heightStyle <| boardHeight model
            , transitionStyle "0.5s ease"
            ]
        ]
        [ div [ class "absolute z-5" ] [ renderResourceBank model ]
        , div [ class "absolute z-2" ] <| renderTiles model
        , div [ class "absolute z-0" ] <| renderLines_ model
        ]


renderResourceBank : Model -> Html msg
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
            [ style
                [ transitionStyle "0.8s ease"
                , transformStyle <| translate offsetX offsetY
                ]
            , classList <| showIf resourceBankVisible
            ]
            [ scoreIcon resourceBank <| ScaleConfig.baseTileSizeY * tileScale ]


resourceBankOffsetX : Model -> Float
resourceBankOffsetX model =
    ScaleConfig.baseTileSizeX
        * toFloat (model.boardDimensions.x - 1)
        * ScaleConfig.tileScaleFactor model.window
        / 2


renderLines_ : Model -> List (Html msg)
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
            [ style [ transitionStyle "0.5s ease" ]
            , classList <| showIf visible
            ]
            [ renderLineLayer model move ]


renderTiles : Model -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (\mv -> renderTile_ (leavingStyles model mv) model mv)


leavingStyles : Model -> Move -> List Style
leavingStyles model (( _, block ) as move) =
    let
        tileState =
            getTileState block
    in
        case tileState of
            Leaving _ order ->
                [ transformStyle <| translate (resourceBankOffsetX model) -100
                , transitionStyle "0.5s ease"
                , transitionDelayStyle <| (order % 5) * 80
                ]

            _ ->
                []


showIf : Bool -> List ( String, Bool )
showIf visible =
    [ ( "o-100", visible )
    , ( "o-0", not visible )
    ]
