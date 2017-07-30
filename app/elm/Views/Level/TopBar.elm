module Views.Level.TopBar exposing (..)

import Data.Color exposing (gold, washedYellow)
import Data.Score exposing (getScoreFor, scoreToString)
import Helpers.Style exposing (backgroundColor, backgroundImage, color, heightStyle, marginTop, px, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Model exposing (..)
import Views.Level.Styles exposing (boardWidth)


topBar : Model -> Html Msg
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
                [ widthStyle <| boardWidth model
                , marginTop -16
                , ( "padding", "0 9px" )
                ]
            , class "flex justify-between"
            ]
            [ div [ class "relative tc" ]
                [ div [ class "bg-center contain pa3", style [ backgroundImage "img/rain.svg" ] ] []
                , renderScore Rain model.scores
                ]
            , div [ class "relative tc" ]
                [ div [ class "bg-center contain pa3", style [ backgroundImage "img/sunflower.svg" ] ] []
                , renderScore Seed model.scores
                ]
            , div [ class "relative tc" ]
                [ div [ class "bg-center contain pa3", style [ backgroundImage "img/sun.svg" ] ] []
                , renderScore Sun model.scores
                ]
            ]
        ]


renderScore : TileType -> Scores -> Html Msg
renderScore tileType scores =
    p
        [ class "ma0 absolute left-0 right-0 f6"
        , style [ ( "bottom", "-1.5em" ) ]
        ]
        [ text <| scoreToString tileType scores ]
