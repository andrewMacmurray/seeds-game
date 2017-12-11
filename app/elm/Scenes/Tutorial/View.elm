module Scenes.Tutorial.View exposing (..)

import Data.Color exposing (darkYellow)
import Data.Level.Board.Block exposing (getTileState)
import Data.Level.Board.Tile exposing (hasLine, isDragging, tileSize)
import Dict
import Helpers.Style exposing (Style, animationStyle, displayStyle, fillModeStyle, heightStyle, marginTop, opacityStyle, pc, transformStyle, transitionDelayStyle, transitionStyle, translate, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Level.Types exposing (Move, TileSize, TileState(..), TileType(..))
import Scenes.Tutorial.Types exposing (..)
import Views.Level.Board exposing (renderLineLayer, renderLines)
import Views.Level.Styles exposing (boardHeight, boardWidth)
import Views.Level.Tile exposing (renderTile_)
import Views.Seed.All exposing (renderSeed)


tutorialView : Model -> Html Msg
tutorialView model =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-999"
        , style [ ( "background-color", "rgba(255, 252, 227, 0.95)" ) ]
        , onClick StartSequence
        ]
        [ div
            [ style
                [ ( "margin-top", pc -5 )
                , transitionStyle "1.5s ease"
                ]
            , classList
                [ ( "o-0", model.containerHidden )
                , ( "o-100", not model.containerHidden )
                ]
            ]
            [ tutorialBoard model
            , p
                [ style [ ( "color", darkYellow ), transitionStyle "0.5s ease" ]
                , classList [ ( "o-0", model.textHidden ), ( "0-100", not model.textHidden ) ]
                ]
                [ text model.text ]
            ]
        ]


tutorialBoard : Model -> Html msg
tutorialBoard model =
    div
        [ class "center relative"
        , classList [ ( "o-0", model.boardHidden ), ( "0-100", not model.boardHidden ) ]
        , style
            [ widthStyle <| boardWidth model.tileSize model.boardScale
            , heightStyle <| boardHeight model.tileSize model.boardScale
            , transitionStyle "0.5s ease"
            ]
        ]
        [ div [ class "absolute z-5" ] [ renderSeedBank model ]
        , div [ class "absolute z-2" ] <| renderTiles model
        , div [ class "absolute z-0" ] <| renderLines_ model
        ]


renderSeedBank : Model -> Html msg
renderSeedBank model =
    div
        [ style
            [ transitionStyle "0.8s ease"
            , transformStyle <| translate model.tileSize.x -100
            , widthStyle model.tileSize.x
            , heightStyle model.tileSize.y
            ]
        , classList
            [ ( "o-0", model.seedBankHidden )
            , ( "o-100", not model.seedBankHidden )
            ]
        ]
        [ renderSeed model.seedType ]


renderLines_ : Model -> List (Html msg)
renderLines_ model =
    model.board
        |> Dict.toList
        |> List.map (fadeLine model.tileSize)


fadeLine : TileSize -> Move -> Html msg
fadeLine tileSize (( _, tile ) as move) =
    if hasLine tile then
        div
            [ style [ transitionStyle "0.5s ease" ]
            , class "o-100"
            ]
            [ renderLineLayer tileSize move ]
    else
        div
            [ style [ transitionStyle "0.5s ease" ]
            , class "o-0"
            ]
            [ renderLineLayer tileSize move ]


renderTiles : Model -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (\mv -> renderTile_ (leavingStyles model.tileSize mv) model mv)


leavingStyles : TileSize -> Move -> List Style
leavingStyles tileSize (( _, block ) as move) =
    let
        tileState =
            getTileState block
    in
        case tileState of
            Leaving Seed order ->
                [ transformStyle <| translate (tileSize.x) -100
                , transitionStyle "0.5s ease"
                , transitionDelayStyle <| (order % 5) * 80
                ]

            _ ->
                []
