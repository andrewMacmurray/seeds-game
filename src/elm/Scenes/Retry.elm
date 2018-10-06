module Scenes.Retry exposing (lifeState, retryView, tryAgain)

import Css.Animation exposing (animation, delay, ease, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Timing exposing (..)
import Css.Transform exposing (..)
import Css.Unit exposing (pc)
import Data.Transit exposing (Transit(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import State exposing (livesLeft)
import Types exposing (..)
import Views.Lives exposing (renderLivesLeft)


retryView : Model -> Html Msg
retryView model =
    div
        [ styles
            [ [ height <| toFloat model.window.height
              , background washedYellow
              ]
            , animation "fade-in" 1000 |> linear
            ]
        , class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        ]
        [ div
            [ style [ Style.property "margin-top" <| pc -8 ]
            , class "tc"
            ]
            [ div [] <| renderLivesLeft <| lifeState model
            , div [ style [ color darkYellow ] ]
                [ p [ class "mt3" ] [ text "You lost a life ..." ]
                , p
                    [ styles [ animation "fade-in" 1000 |> delay 2500 |> ease ]
                    , class "o-0"
                    ]
                    [ text "But don't feel disheartened" ]
                ]
            , div
                [ styles
                    [ animation "bounce-up" 1500
                        |> delay 3000
                        |> linear
                    , [ transform [ translate 0 (toFloat <| model.window.height + 100) ] ]
                    ]
                ]
                [ tryAgain model ]
            ]
        ]


lifeState : Model -> Transit Int
lifeState model =
    let
        lives =
            model.timeTillNextLife |> livesLeft |> floor
    in
    case model.scene of
        Transition _ ->
            Static lives

        _ ->
            Transitioning lives


tryAgain : Model -> Html Msg
tryAgain model =
    div [ style [ marginTop 50 ], class "pointer" ]
        [ div
            [ styles
                [ [ background lightGreen
                  , color "white"
                  , paddingLeft 25
                  , paddingRight 20
                  , paddingTop 15
                  , paddingBottom 15
                  ]
                , leftPill
                ]
            , class "dib"
            , onClick GoToHub
            ]
            [ p [ class "ma0" ] [ text "X" ] ]
        , div
            [ styles
                [ [ background mediumGreen
                  , color "white"
                  , paddingLeft 25
                  , paddingRight 20
                  , paddingTop 15
                  , paddingBottom 15
                  ]
                , rightPill
                ]
            , class "dib"
            , onClick RestartLevel
            ]
            [ p [ class "ma0" ] [ text "Try again?" ] ]
        ]
