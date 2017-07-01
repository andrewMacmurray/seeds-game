module Views.Level.TopBar exposing (..)

import Data.Score exposing (getScoreFor, scoreToString)
import Helpers.Style exposing (backgroundImage, px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Level.Styles exposing (boardWidth)


topBar : Model -> Html Msg
topBar model =
    div
        [ class "w-100 bg-washed-yellow flex items-center justify-center fixed top-0 z-3"
        , style [ ( "height", px model.topBarHeight ) ]
        ]
        [ div
            [ style [ ( "width", px <| boardWidth model ), ( "margin-top", "-1em" ), ( "padding", "0 9px" ) ]
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
