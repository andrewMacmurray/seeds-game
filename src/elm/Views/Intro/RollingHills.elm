module Views.Intro.RollingHills exposing (..)

import Data.Visibility exposing (..)
import Helpers.Css.Style exposing (svgStyle, svgStyles, svgTranslate, widthStyle)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform as Transform exposing (transformSvg, translate)
import Helpers.Css.Transition exposing (transitionSvg)
import Html exposing (Html, div)
import Html.Attributes
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower exposing (sunflower)


rollingHills : Visibility -> Html msg
rollingHills vis =
    div [ id "rolling-hills" ]
        [ div [ class "relative z-5 center", Html.Attributes.style [ widthStyle 200 ] ] [ sunflower 0 ]
        , div [ class "fixed w-100 bottom-0 left-0 z-1" ] [ hills vis ]
        ]


hills : Visibility -> Svg msg
hills vis =
    Svg.svg [ viewBox "0 0 1000 800", width "100%", class "absolute bottom-0", hillsStyle vis ]
        [ Svg.g [ fill "none", fillRule "evenodd", style "transform: translate(-500px)" ]
            [ Svg.g [ hillOffset 1200 300 vis ]
                [ Svg.circle [ cx "1325", cy "650", fill "#325448", r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill "#1F7D5C", r "650" ] []
                ]
            , Svg.g [ hillOffset 900 400 vis ]
                [ Svg.circle [ cx "650", cy "650", fill "#5BCA78", r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill "#40914E", r "650" ] []
                ]
            , Svg.g [ hillOffset 600 500 vis ]
                [ Svg.circle [ cx "1325", cy "650", fill "#288868", r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill "#3A5E52", r "650" ] []
                , renderFlowers 600 vis
                ]
            , Svg.g [ hillOffset 300 600 vis ]
                [ Svg.circle [ cx "650", cy "650", fill "#56B466", r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill "#62DE83", r "650" ] []
                , renderFlowers 300 vis
                ]
            , Svg.g [ hillOffset 0 700 vis ]
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


hillOffset : Float -> Float -> Visibility -> Attribute msg
hillOffset delay offset vis =
    let
        visibleStyles =
            [ transformSvg [ translate 0 offset ]
            , transitionSvg
                { property = "all"
                , duration = 2000
                , delay = Just delay
                , timing = CubicBezier 0 0 0 1
                }
            ]
    in
        case vis of
            Entering ->
                svgStyles visibleStyles

            Visible ->
                svgStyles visibleStyles

            _ ->
                svgStyles [ transformSvg [ translate 0 800 ] ]


renderFlowers : Float -> Visibility -> Svg msg
renderFlowers delay vis =
    case vis of
        Visible ->
            flowers delay

        _ ->
            Svg.g [] []


flowers : Float -> Svg msg
flowers delay =
    Svg.g [ class "dn db-ns" ] [ flowersLeft delay, flowersRight delay ]


flowersRight : Float -> Svg msg
flowersRight delay =
    Svg.g []
        [ Svg.g
            [ svgStyles [ originCenter, transformSvg [ translate 600 -360, Transform.scale 0.08 ] ] ]
            [ sunflower <| delay + 300 ]
        , Svg.g
            [ svgStyles [ originCenter, transformSvg [ translate 700 -390, Transform.scale 0.06 ] ] ]
            [ sunflower <| delay + 450 ]
        , Svg.g
            [ svgStyles [ originCenter, transformSvg [ translate 800 -400, Transform.scale 0.05 ] ] ]
            [ sunflower <| delay + 650 ]
        ]


flowersLeft : Float -> Svg msg
flowersLeft delay =
    Svg.g []
        [ Svg.g [ svgStyles [ originCenter, transformSvg [ translate 400 -350, Transform.scale 0.08 ] ] ] [ sunflower <| delay + 0 ]
        , Svg.g [ svgStyles [ originCenter, transformSvg [ translate 300 -380, Transform.scale 0.06 ] ] ] [ sunflower <| delay + 250 ]
        , Svg.g [ svgStyles [ originCenter, transformSvg [ translate 200 -400, Transform.scale 0.05 ] ] ] [ sunflower <| delay + 600 ]
        ]


originCenter : String
originCenter =
    "transform-origin: center"
