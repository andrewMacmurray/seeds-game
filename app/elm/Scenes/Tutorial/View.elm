module Scenes.Tutorial.View exposing (..)

import Dict
import Helpers.Style exposing (heightStyle, marginTop, pc, transitionStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Tutorial.Types exposing (..)
import Views.Level.Board exposing (renderLines)
import Views.Level.Styles exposing (boardHeight, boardWidth)
import Views.Level.Tile exposing (renderTile_)


tutorialView : Model -> Html Msg
tutorialView model =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-999"
        , style [ ( "background-color", "rgba(255, 252, 227, 0.95)" ) ]
        , onClick DragSequence
        ]
        [ div [ style [ ( "margin-top", pc -10 ) ] ]
            [ tutorialBoard model
            , p [] [ text "Connect seed pods to grow seeds" ]
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
        [ div [ class "absolute z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : Model -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile_ [] model)
