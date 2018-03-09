module Scenes.Retry.View exposing (..)

import Config.Color exposing (..)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Hub.Types exposing (Model, Msg(RestartLevel, GoToHub))
import Views.Icons.Heart exposing (heart)


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
                [ p [ class "mt3" ] [ text "You lost a life" ]
                , p [] [ text "But don't feel disheartened" ]
                ]
            , div
                [ style
                    [ animationStyle "1.5s bounce-up 1.5s linear forwards"
                    , transformStyle <| translateY (model.window.height + 100)
                    ]
                ]
                [ tryAgain model ]
            ]
        ]


tryAgain : Model -> Html Msg
tryAgain model =
    div [ style [ marginTop 50 ], class "pointer" ]
        [ div
            [ style
                [ background lightOrange
                , color "white"
                , ( "border-top-left-radius", "9999px" )
                , ( "border-bottom-left-radius", "9999px" )
                ]
            , class "pa3 dib"
            , onClick GoToHub
            ]
            [ p [ class "ma0" ] [ text "X" ] ]
        , div
            [ style
                [ background fadedOrange
                , color "white"
                , ( "border-top-right-radius", "9999px" )
                , ( "border-bottom-right-radius", "9999px" )
                ]
            , class "pa3 dib"
            , onClick RestartLevel
            ]
            [ p [ class "ma0" ] [ text "Try again?" ] ]
        ]


life : ( Bool, Bool ) -> Html msg
life ( active, currentLife ) =
    let
        animation =
            if currentLife then
                animationStyle "heartbeat 1s infinite"
            else
                emptyStyle
    in
        div
            [ style
                [ widthStyle 35
                , heightStyle 35
                , marginLeft 10
                , marginRight 10
                , animation
                ]
            , class "br-100 dib"
            ]
            [ heart active ]


livesLeft : Int -> List (Html msg)
livesLeft lives =
    List.range 1 5
        |> List.map (\n -> ( n <= lives, n == lives ))
        |> List.map life
