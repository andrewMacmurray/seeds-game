module Scenes.Hub.View exposing
    ( hubTopBar
    , hubView
    , renderCountDown
    , renderSecond
    , renderTime
    , timeLeft
    )

import Config.Color exposing (darkYellow, pinkRed, washedYellow)
import Data.Transit exposing (Transit(..))
import Helpers.Css.Style exposing (..)
import Helpers.Css.Transform exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import State exposing (livesLeft)
import Types exposing (..)
import Views.Hub.InfoWindow exposing (handleHideInfo, info)
import Views.Hub.World exposing (renderWorlds)
import Views.Lives exposing (renderLivesLeft)


hubView : Model -> Html Msg
hubView model =
    div [ handleHideInfo model ]
        [ hubTopBar model
        , info model
        , div
            [ class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            , id "hub"
            , (\( a, b ) -> style a b) (heightStyle model.window.height)
            ]
            (renderWorlds model)
        ]


hubTopBar : Model -> Html msg
hubTopBar model =
    let
        lives =
            model.timeTillNextLife
                |> livesLeft
                |> floor
                |> Transitioning
    in
    div
        [ class "w-100 fixed z-3 top-0 tc pa1 pa2-ns"
        , (\( a, b ) -> style a b) (background washedYellow)
        ]
        [ div [ (\( a, b ) -> style a b) (transformStyle [ scale 0.5 ]) ] <| renderLivesLeft lives
        , div [ class "f7", (\( a, b ) -> style a b) (color darkYellow) ] [ renderCountDown model.timeTillNextLife ]
        ]


renderCountDown : Float -> Html msg
renderCountDown timeRemaining =
    case timeLeft timeRemaining of
        Nothing ->
            p [ class "ma1 mt0" ] [ text "full life" ]

        Just t ->
            div []
                [ p [ (\( a, b ) -> style a b) (marginTop -2), class "dib ma1 mt0" ] [ text "Next life in: " ]
                , p [ (\( a, b ) -> style a b) (color pinkRed), class "dib ma1 mt0" ] [ text <| renderTime t ]
                ]


renderTime : ( Int, Int ) -> String
renderTime ( m, s ) =
    String.fromInt m ++ ":" ++ renderSecond s


timeLeft : Float -> Maybe ( Int, Int )
timeLeft timeRemaining =
    -- let
    --     d =
    --         Date.fromTime timeRemaining
    -- in
    -- FIXME
    if timeRemaining == 0 then
        Nothing

    else
        -- Just ( modBy 5 (minute d), second d )
        Just ( 1, 1 )


renderSecond : Int -> String
renderSecond n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n
