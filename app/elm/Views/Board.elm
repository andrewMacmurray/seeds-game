module Views.Board exposing (..)

import Data.Move exposing (isInCurrentMove)
import Data.Tiles exposing (tilePaddingMap, tileToCssClass)
import Dict
import Helpers.Style exposing (px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown, onMouseEnter)
import Model exposing (..)


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


renderTile : Model -> ( Coord, Tile ) -> Html Msg
renderTile model (( coord, tile ) as move) =
    div
        [ style <| baseTileStyles model
        , class "dib flex items-center justify-center relative"
        , onMouseDown <| StartMove move
        , onMouseEnter <| CheckMove move
        ]
        [ div
            [ class <| "br-100 absolute all ease t3 " ++ tileToCssClass tile ++ " " ++ draggingClasses model move
            , style [ ( "padding", tilePaddingMap tile ) ]
            ]
            []
        ]


draggingClasses : Model -> ( Coord, Tile ) -> String
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
