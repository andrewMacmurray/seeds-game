module Views.Intro.RollingHills exposing (..)

import Scenes.Intro.Types exposing (..)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower exposing (sunflower)


rollingHills : Visibility -> Svg msg
rollingHills vis =
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
                , renderFlowers 1000 vis
                ]
            , Svg.g [ transform "translate(0 600)", class "hill" ]
                [ Svg.circle [ cx "650", cy "650", fill "#56B466", r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill "#62DE83", r "650" ] []
                , renderFlowers 500 vis
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
            style "opacity: 0; transition: 1s ease"

        Leaving ->
            style "opacity: 0; transition: 1s ease"

        Entering ->
            style "opacity: 1; transition: 1s ease"

        Visible ->
            style "opacity: 1; transition: 1s ease"


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
        [ Svg.g [ transform "translate(600 -360) scale(0.08)", style "transform-origin: center" ] [ sunflower <| offset + 500 ]
        , Svg.g [ transform "translate(700 -390) scale(0.06)", style "transform-origin: center" ] [ sunflower <| offset + 750 ]
        , Svg.g [ transform "translate(800 -400) scale(0.05)", style "transform-origin: center" ] [ sunflower <| offset + 1000 ]
        ]


flowersLeft : Float -> Svg msg
flowersLeft offset =
    Svg.g []
        [ Svg.g [ transform "translate(400 -350) scale(0.08)", style "transform-origin: center" ] [ sunflower <| offset + 0 ]
        , Svg.g [ transform "translate(300 -380) scale(0.06)", style "transform-origin: center" ] [ sunflower <| offset + 250 ]
        , Svg.g [ transform "translate(200 -400) scale(0.05)", style "transform-origin: center" ] [ sunflower <| offset + 600 ]
        ]
