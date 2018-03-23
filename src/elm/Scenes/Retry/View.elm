module Scenes.Retry.View exposing (..)

import Config.Color exposing (..)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (..)
import Views.Lives exposing (livesLeft)


retryView : Model -> Html Msg
retryView model =
    div
        [ class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        , style
            [ heightStyle model.window.height
            , background washedYellow
            , animationStyle "fade-in 1s linear"
            ]
        ]
        [ div [ class "tc", style [ ( "margin-top", pc -8 ) ] ]
            [ div [] <| livesLeft model.lives
            , div [ style [ color darkYellow ] ]
                [ p [ class "mt3" ] [ text "You lost a life ..." ]
                , p
                    [ style
                        [ animationStyle "1s fade-in 2.5s forwards"
                        ]
                    , class "o-0"
                    ]
                    [ text "But don't feel disheartened" ]
                ]
            , div
                [ style
                    [ animationStyle "1.5s bounce-up 3s linear forwards"
                    , transformStyle <| translateY <| model.window.height + 100
                    ]
                ]
                [ tryAgain model ]
            ]
        ]


tryAgain : Model -> Html Msg
tryAgain model =
    div [ style [ marginTop 50 ], class "pointer" ]
        [ div
            [ styles [ [ background lightGreen, color "white" ], leftPill ]
            , class "pa3 dib"
            , onClick GoToHub
            ]
            [ p [ class "ma0" ] [ text "X" ] ]
        , div
            [ styles [ [ background mediumGreen, color "white" ], rightPill ]
            , class "pa3 dib"
            , onClick RestartLevel
            ]
            [ p [ class "ma0" ] [ text "Try again?" ] ]
        ]
