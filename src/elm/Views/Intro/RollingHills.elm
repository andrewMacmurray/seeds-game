module Views.Intro.RollingHills exposing (..)

import Data.Visibility exposing (..)
import Html exposing (Html, div)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower exposing (sunflower)


rollingHills : Visibility -> Html msg
rollingHills vis =
    div []
        [ div [ class "flex relative z-2" ]
            [ sunflower 0 ]
        , div [ class "fixed w-100 bottom-0 left-0 z-1" ] [ hills vis ]
        ]


hills : Visibility -> Svg msg
hills vis =
    Svg.svg [ viewBox "0 0 1000 800", width "100%", class "absolute bottom-0", hillsStyle vis ]
        [ Svg.g [ fill "none", fillRule "evenodd", transform "translate(-500)" ]
            [ Svg.g [ transform "translate(0 300)", class "hill" ]
                [ Svg.circle [ cx "1325", cy "650", fill "#325448", r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill "#1F7D5C", r "650" ] []
                ]
            , Svg.g [ transform "translate(0 400)", class "hill" ]
                [ Svg.circle [ cx "650", cy "650", fill "#5BCA78", r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill "#40914E", r "650" ] []
                ]
            , Svg.g [ transform "translate(0 500)", class "hill" ]
                [ Svg.circle [ cx "1325", cy "650", fill "#288868", r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill "#3A5E52", r "650" ] []
                , renderFlowers 600 vis
                ]
            , Svg.g [ transform "translate(0 600)", class "hill" ]
                [ Svg.circle [ cx "650", cy "650", fill "#56B466", r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill "#62DE83", r "650" ] []
                , renderFlowers 300 vis
                ]
            , Svg.g [ transform "translate(0 700)", class "hill" ]
                [ Svg.circle [ cx "1325", cy "650", fill "#268135", r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill "#15674D", r "650" ] []
                , renderFlowers 0 vis
                ]
            ]
        ]


hillsStyle : Visibility -> Attribute msg
hillsStyle vis =
    case vis of
        Hidden ->
            style "opacity: 0"

        Leaving ->
            style "opacity: 0"

        Entering ->
            style "opacity: 1"

        Visible ->
            style "opacity: 1"


renderFlowers : Float -> Visibility -> Svg msg
renderFlowers offset vis =
    case vis of
        Visible ->
            flowers offset

        _ ->
            Svg.g [] []


flowers : Float -> Svg msg
flowers offset =
    Svg.g [] [ flowersLeft offset, flowersRight offset ]


flowersRight : Float -> Svg msg
flowersRight offset =
    Svg.g []
        [ Svg.g
            [ transform "translate(600 -360) scale(0.08)"
            , style "transform-origin: center"
            ]
            [ sunflower <| offset + 300 ]
        , Svg.g
            [ transform "translate(700 -390) scale(0.06)"
            , style "transform-origin: center"
            ]
            [ sunflower <| offset + 450 ]
        , Svg.g
            [ transform "translate(800 -400) scale(0.05)"
            , style "transform-origin: center"
            ]
            [ sunflower <| offset + 650 ]
        ]


flowersLeft : Float -> Svg msg
flowersLeft offset =
    Svg.g []
        [ Svg.g [ transform "translate(400 -350) scale(0.08)", style "transform-origin: center" ] [ sunflower <| offset + 0 ]
        , Svg.g [ transform "translate(300 -380) scale(0.06)", style "transform-origin: center" ] [ sunflower <| offset + 250 ]
        , Svg.g [ transform "translate(200 -400) scale(0.05)", style "transform-origin: center" ] [ sunflower <| offset + 600 ]
        ]
