module Scenes.Retry exposing
    ( Msg
    , view
    )

import Css.Animation exposing (animation, delay, ease, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Unit exposing (pc)
import Data.Lives as Lives
import Data.Transit exposing (Transit(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Shared
import Views.Lives exposing (renderLivesLeft)


type alias Msg msg =
    { goToHub : msg
    , restartLevel : msg
    }


view : Msg msg -> Shared.Data -> Html msg
view msgConfig model =
    div
        [ style
            [ height <| toFloat model.window.height
            , background washedYellow
            , animation "fade-in" 1000 [ linear ]
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
                    [ style [ animation "fade-in" 1000 [ delay 2500, ease ] ]
                    , class "o-0"
                    ]
                    [ text "But don't feel disheartened" ]
                ]
            , div
                [ style
                    [ animation "bounce-up" 1500 [ delay 3000, linear ]
                    , transform [ translate 0 (toFloat <| model.window.height + 100) ]
                    ]
                ]
                [ tryAgain msgConfig model ]
            ]
        ]


lifeState : Shared.Data -> Transit Int
lifeState model =
    model.lives
        |> Lives.remaining
        |> Transitioning


tryAgain : Msg msg -> Shared.Data -> Html msg
tryAgain { goToHub, restartLevel } model =
    div [ style [ marginTop 50 ], class "pointer" ]
        [ div
            [ style
                [ background lightGreen
                , color "white"
                , paddingLeft 25
                , paddingRight 20
                , paddingTop 15
                , paddingBottom 15
                , leftPill
                ]
            , class "dib"
            , onClick goToHub
            ]
            [ p [ class "ma0" ] [ text "X" ] ]
        , div
            [ style
                [ background mediumGreen
                , color "white"
                , paddingLeft 25
                , paddingRight 20
                , paddingTop 15
                , paddingBottom 15
                , rightPill
                ]
            , class "dib"
            , onClick restartLevel
            ]
            [ p [ class "ma0" ] [ text "Try again?" ] ]
        ]
