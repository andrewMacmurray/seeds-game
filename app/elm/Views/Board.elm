module Views.Board exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown, onMouseEnter)
import Data.Moves exposing (isInCurrentMove)
import Data.Tiles exposing (tilePaddingMap, tileColorMap)
import Helpers.Style exposing (px, classes)
import Dict


renderBoard : Model -> Html Msg
renderBoard model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)
        |> renderContainer model


renderContainer : Model -> List (Html Msg) -> Html Msg
renderContainer model =
    div
        [ class "relative z-3 center mt5 flex flex-wrap"
        , style [ ( "width", px <| boardWidth model ) ]
        ]


boardWidth : Model -> Int
boardWidth { tileSettings, boardSettings } =
    tileSettings.sizeX * boardSettings.sizeX


renderTile : Model -> Move -> Html Msg
renderTile model (( coord, tile ) as move) =
    div
        [ style (baseTileStyles model)
        , class "dib flex items-center justify-center relative pointer"
        , onMouseDown (StartMove move)
        , onMouseEnter (CheckMove move)
        ]
        [ innerTile model move ]


innerTile : Model -> Move -> Html Msg
innerTile model (( _, tile ) as move) =
    let
        innerTileClasses =
            classes
                [ "br-100 absolute all ease t3"
                , tileColorMap tile
                , draggingClasses model move
                ]
    in
        div
            [ class innerTileClasses
            , style [ ( "padding", tilePaddingMap tile ) ]
            ]
            []


draggingClasses : Model -> Move -> String
draggingClasses model coord =
    if isInCurrentMove coord model.currentMove then
        "scale-half"
    else
        "scale-full"


baseTileStyles : Model -> List ( String, String )
baseTileStyles { tileSettings } =
    [ ( "width", px tileSettings.sizeX )
    , ( "height", px tileSettings.sizeY )
    ]
