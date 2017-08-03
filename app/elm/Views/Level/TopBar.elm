module Views.Level.TopBar exposing (..)

import Data.Board.Score exposing (getScoreFor, scoreTileTypes, scoreToString)
import Data.Color exposing (gold, washedYellow)
import Helpers.Style exposing (backgroundColor, backgroundImage, color, heightStyle, marginLeft, marginRight, marginTop, px, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Model exposing (..)


topBar : Model -> Html msg
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
            (List.map (renderScore model.scores) (scoreTileTypes model.tileProbabilities))
        ]


renderScore : Scores -> TileType -> Html msg
renderScore scores tileType =
    div
        [ class "relative tc"
        , style
            [ marginRight 16
            , marginLeft 16
            ]
        ]
        [ renderScoreIcon tileType
        , p
            [ class "ma0 absolute left-0 right-0 f6"
            , style [ ( "bottom", "-1.5em" ) ]
            ]
            [ text <| scoreToString tileType scores ]
        ]


renderScoreIcon : TileType -> Html msg
renderScoreIcon tileType =
    case tileType of
        Sun ->
            scoreIcon "img/sun.svg"

        Rain ->
            scoreIcon "img/rain.svg"

        Seed ->
            scoreIcon "img/sunflower.svg"

        _ ->
            span [] []


scoreIcon : String -> Html msg
scoreIcon url =
    div [ class "bg-center contain pa3", style [ backgroundImage url ] ] []
