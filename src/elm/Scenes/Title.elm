module Scenes.Title exposing (..)

import Config.Color exposing (..)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Types exposing (Model, Msg(..))
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)
import Window


titleView : Model -> Html Msg
titleView model =
    div [ class "relative z-5 tc" ]
        [ div
            [ style [ marginTop <| percentWindowHeight 17 model ] ]
            [ seeds ]
        , p
            [ class "f3 tracked-mega"
            , styles [ [ color darkYellow, marginTop 45 ], fadeStyles 1500 500 ]
            ]
            [ text "seeds" ]
        , button
            [ class "outline-0 br4 pv2 ph3 f5 pointer sans-serif tracked-mega"
            , onClick GoToHub
            , styles
                [ [ ( "border", "none" )
                  , marginTop 15
                  , color white
                  , backgroundColor lightOrange
                  ]
                , fadeStyles 800 2500
                ]
            ]
            [ text "PLAY" ]
        ]


percentWindowHeight : Float -> { a | window : Window.Size } -> Float
percentWindowHeight percent model =
    toFloat model.window.height / 100 * percent


seeds : Html msg
seeds =
    div
        [ style [ maxWidth 450 ]
        , class "flex center ph3"
        ]
        (List.map2 fadeSeeds
            (seedDelays 500)
            [ foxglove
            , marigold
            , sunflower
            , lupin
            , rose
            ]
        )


seedDelays : Float -> List Float
seedDelays interval =
    [ 3, 2, 1, 2, 3 ] |> List.map ((*) interval)


fadeSeeds : Float -> Html msg -> Html msg
fadeSeeds delay seed =
    div
        [ style <| fadeStyles 1000 delay
        , class "mh2"
        ]
        [ seed ]


fadeStyles : Float -> Float -> List Style
fadeStyles duration delay =
    [ opacityStyle 0
    , animationWithOptionsStyle
        { name = "fade-in"
        , duration = duration
        , delay = Just delay
        , timing = Linear
        , fill = Forwards
        , iteration = Nothing
        }
    ]
