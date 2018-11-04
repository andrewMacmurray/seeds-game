module Views.Intro.RollingHills exposing
    ( flowers
    , flowersLeft
    , flowersRight
    , hillOffset
    , hills
    , hillsStyle
    , originCenter
    , renderFlowers
    , rollingHills
    )

import Config.Scale exposing (ScreenSize(..), screenSize)
import Css.Animation as Animation exposing (animation)
import Css.Style as Style exposing (Style, opacity, svgStyle, svgStyles, transformOrigin)
import Css.Transform as Transform exposing (translate)
import Css.Transition exposing (cubicBezier, delay, transitionAll)
import Data.Visibility exposing (..)
import Html exposing (Html, div)
import Html.Attributes
import Shared exposing (Window)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower as Sunflower


rollingHills : Window -> Visibility -> Html msg
rollingHills window vis =
    div [ id "rolling-hills" ]
        [ div [ class "relative z-5 center", svgStyle <| Style.width 200 ] [ Sunflower.animated 0 ]
        , div [ class "fixed w-100 bottom-0 left-0 z-1" ] [ hills window vis ]
        ]


hills : Window -> Visibility -> Svg msg
hills window vis =
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
                , renderFlowers 600 window vis
                ]
            , Svg.g [ hillOffset 300 600 vis ]
                [ Svg.circle [ cx "650", cy "650", fill "#56B466", r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill "#62DE83", r "650" ] []
                , renderFlowers 300 window vis
                ]
            , Svg.g [ hillOffset 0 700 vis ]
                [ Svg.circle [ cx "1325", cy "650", fill "#268135", r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill "#15674D", r "650" ] []
                , renderFlowers 0 window vis
                ]
            ]
        ]


hillsStyle : Visibility -> Attribute msg
hillsStyle vis =
    case vis of
        Hidden ->
            svgStyle <| Style.opacity 0

        Leaving ->
            svgStyle <| Style.opacity 0

        Entering ->
            svgStyle <| Style.opacity 1

        Visible ->
            svgStyle <| Style.opacity 1


hillOffset : Int -> Float -> Visibility -> Attribute msg
hillOffset ms offset vis =
    let
        visibleStyles =
            [ Style.transform [ translate 0 offset ]
            , transitionAll 2000 [ delay ms, cubicBezier 0 0 0 1 ]
            ]
    in
    case vis of
        Entering ->
            svgStyles visibleStyles

        Visible ->
            svgStyles visibleStyles

        _ ->
            svgStyles [ Style.transform [ translate 0 800 ] ]


renderFlowers : Int -> Window -> Visibility -> Svg msg
renderFlowers delay window vis =
    case vis of
        Visible ->
            flowers delay window

        _ ->
            Svg.g [] []


flowers : Int -> Window -> Svg msg
flowers delay window =
    Svg.g [ class "db" ] [ flowersLeft delay window, flowersRight delay window ]


flowersRight : Int -> Window -> Svg msg
flowersRight delay window =
    Svg.g []
        [ Svg.g
            [ svgStyles [ originCenter, Style.transform [ translate 600 -360, Transform.scale 0.08 ] ] ]
            [ sunflower window <| delay + 300 ]
        , Svg.g
            [ svgStyles [ originCenter, Style.transform [ translate 700 -390, Transform.scale 0.06 ] ] ]
            [ sunflower window <| delay + 450 ]
        , Svg.g
            [ svgStyles [ originCenter, Style.transform [ translate 800 -400, Transform.scale 0.05 ] ] ]
            [ sunflower window <| delay + 650 ]
        ]


flowersLeft : Int -> Window -> Svg msg
flowersLeft delay window =
    Svg.g []
        [ Svg.g [ svgStyles [ originCenter, Style.transform [ translate 400 -350, Transform.scale 0.08 ] ] ] [ sunflower window <| delay + 0 ]
        , Svg.g [ svgStyles [ originCenter, Style.transform [ translate 300 -380, Transform.scale 0.06 ] ] ] [ sunflower window <| delay + 250 ]
        , Svg.g [ svgStyles [ originCenter, Style.transform [ translate 200 -400, Transform.scale 0.05 ] ] ] [ sunflower window <| delay + 600 ]
        ]


sunflower : Window -> Int -> Svg msg
sunflower window delay =
    case screenSize window of
        Small ->
            Svg.g
                [ svgStyles
                    [ animation "fade-in" 3000 [ Animation.delay <| delay ]
                    , Style.opacity 0
                    ]
                ]
                [ Sunflower.static ]

        _ ->
            Sunflower.animated delay


originCenter : Style
originCenter =
    transformOrigin "center"
