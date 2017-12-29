module Views.Board.TopBar exposing (..)

import Data.Color exposing (gold, washedYellow)
import Data.Level.Board.Tile exposing (seedBackgrounds)
import Data.Level.Score exposing (getScoreFor, scoreTileTypes, scoreToString)
import Helpers.Style exposing (backgroundColor, backgroundImage, color, heightStyle, marginLeft, marginRight, marginTop, px, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Types as Level exposing (..)


topBar : Level.Model -> Html msg
topBar model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , style
            [ heightStyle model.topBarHeight
            , color gold
            , backgroundColor washedYellow
            ]
        ]
        [ div
            [ style
                [ marginTop -16
                , ( "padding", "0 9px" )
                ]
            , class "flex justify-center"
            ]
            (List.map (renderScore model) (scoreTileTypes model.tileSettings))
        ]


renderScore : Level.Model -> TileType -> Html msg
renderScore model tileType =
    let
        scoreMargin =
            model.scoreIconSize // 2
    in
        div
            [ class "relative tc"
            , style
                [ marginRight scoreMargin
                , marginLeft scoreMargin
                ]
            ]
            [ renderScoreIcon model tileType
            , p
                [ class "ma0 absolute left-0 right-0 f6"
                , style [ ( "bottom", "-1.5em" ) ]
                ]
                [ text <| scoreToString tileType model.scores ]
            ]


renderScoreIcon : Level.Model -> TileType -> Html msg
renderScoreIcon model tileType =
    case tileType of
        Sun ->
            scoreIcon model "img/sun.svg"

        Rain ->
            scoreIcon model "img/rain.svg"

        Seed ->
            scoreIcon model <| seedBackgrounds model.seedType

        _ ->
            span [] []


scoreIcon : Level.Model -> String -> Html msg
scoreIcon { scoreIconSize } url =
    div
        [ class "bg-center contain"
        , style
            [ backgroundImage url
            , widthStyle scoreIconSize
            , heightStyle scoreIconSize
            ]
        ]
        []
