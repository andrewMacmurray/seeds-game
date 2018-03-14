module Scenes.Retry.View exposing (..)

import Config.Color exposing (..)
import Data.Transit as Transit exposing (Transit)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Hub.Types exposing (..)
import Views.Icons.Heart exposing (breakingHeart, brokenHeart, heart)


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


livesLeft : Transit Int -> List (Html msg)
livesLeft lifeState =
    let
        lives =
            Transit.val lifeState
    in
        List.range 1 5
            |> List.map (\n -> ( n <= lives, n == lives, n == lives + 1, lifeState ))
            |> List.map life


life : ( Bool, Bool, Bool, Transit Int ) -> Html msg
life ( active, currentLife, breaking, lifeState ) =
    let
        animation =
            if currentLife then
                animationStyle "heartbeat 1s infinite"
            else
                emptyStyle

        visibleHeart =
            if active then
                heart
            else if breaking && Transit.isTransitioning lifeState then
                breakingHeart
            else
                brokenHeart

        adjustScale =
            if active then
                emptyStyle
            else
                transformStyle <| scale 1.11
    in
        div
            [ style
                [ widthStyle 35
                , heightStyle 35
                , marginLeft 10
                , marginRight 10
                , animation
                , adjustScale
                ]
            , class "dib"
            ]
            [ visibleHeart ]
