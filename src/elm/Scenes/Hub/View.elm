module Scenes.Hub.View exposing (..)

import Config.Color exposing (darkYellow, pinkRed, washedYellow)
import Date exposing (minute, second)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types exposing (..)
import Time exposing (Time)
import Views.Hub.InfoWindow exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Views.Lives exposing (livesLeft)


hubView : Model -> Html Msg
hubView model =
    div [ handleHideInfo model ]
        [ hubTopBar model
        , info model
        , div
            [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            , id "hub"
            , style [ heightStyle model.window.height ]
            ]
            (renderWorlds model)
        ]


hubTopBar : Model -> Html msg
hubTopBar model =
    div
        [ class "w-100 fixed z-3 top-0 tc pa1 pa2-ns"
        , style [ background washedYellow ]
        ]
        [ div [ style [ transformStyle <| scale 0.5 ] ] <| livesLeft model.lives
        , div [ class "f7", style [ color darkYellow ] ] [ renderCountDown model.timeTillNextLife ]
        ]


renderCountDown : Time -> Html msg
renderCountDown timeRemaining =
    case timeLeft timeRemaining of
        Nothing ->
            p [ class "ma1 mt0" ] [ text "full life" ]

        Just t ->
            div []
                [ p [ style [ marginTop -2 ], class "dib ma1 mt0" ] [ text "Next life in: " ]
                , p [ style [ color pinkRed ], class "dib ma1 mt0" ] [ text <| renderTime t ]
                ]


renderTime : ( Int, Int ) -> String
renderTime ( m, s ) =
    toString m ++ ":" ++ renderSecond s


timeLeft : Time -> Maybe ( Int, Int )
timeLeft timeRemaining =
    let
        d =
            Date.fromTime timeRemaining
    in
        if timeRemaining == 0 then
            Nothing
        else
            Just ( minute d % 5, second d )


renderSecond : Int -> String
renderSecond n =
    if n < 10 then
        "0" ++ toString n
    else
        toString n
