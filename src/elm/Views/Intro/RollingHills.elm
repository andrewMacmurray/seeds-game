module Views.Intro.RollingHills exposing
    ( State(..)
    , view
    )

import Css.Animation as Animation exposing (animation)
import Css.Color as Color
import Css.Style as Style exposing (Style, opacity, svgStyle, svgStyles, transformOrigin)
import Css.Transform as Transform exposing (translate)
import Css.Transition exposing (cubicBezier, delay, transitionAll)
import Data.Window as Window exposing (Window)
import Html exposing (Html, div)
import Html.Attributes
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower as Sunflower


type State
    = Blooming
    | Entering
    | Hidden


view : Window -> State -> Html msg
view window vis =
    div [ id "rolling-hills" ]
        [ div [ class "relative z-5 center", svgStyle <| Style.width 200 ] [ Sunflower.animated 0 ]
        , div [ class "fixed w-100 bottom-0 left-0 z-1" ] [ hills window vis ]
        ]


hills : Window -> State -> Svg msg
hills window vis =
    Svg.svg [ viewBox "0 0 1000 800", width "100%", class "absolute bottom-0", hillsStyle vis ]
        [ Svg.g [ fill "none", fillRule "evenodd", style "transform: translate(-500px)" ]
            [ Svg.g [ hillOffset 1200 300 vis ]
                [ Svg.circle [ cx "1325", cy "650", fill Color.ashGreen, r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill Color.seaGreen, r "650" ] []
                ]
            , Svg.g [ hillOffset 900 400 vis ]
                [ Svg.circle [ cx "650", cy "650", fill Color.meadowGreen, r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill Color.pineGreen, r "650" ] []
                ]
            , Svg.g [ hillOffset 600 500 vis ]
                [ Svg.circle [ cx "1325", cy "650", fill Color.seaGreen, r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill Color.ashGreen, r "650" ] []
                , renderFlowers 600 window vis
                ]
            , Svg.g [ hillOffset 300 600 vis ]
                [ Svg.circle [ cx "650", cy "650", fill Color.lightPine, r "650" ] []
                , Svg.circle [ cx "1325", cy "650", fill Color.meadowGreen, r "650" ] []
                , renderFlowers 300 window vis
                ]
            , Svg.g [ hillOffset 0 700 vis ]
                [ Svg.circle [ cx "1325", cy "650", fill Color.deepPine, r "650" ] []
                , Svg.circle [ cx "650", cy "650", fill Color.darkSeaGreen, r "650" ] []
                , renderFlowers 0 window vis
                ]
            ]
        ]


hillsStyle : State -> Attribute msg
hillsStyle vis =
    case vis of
        Hidden ->
            svgStyle <| Style.opacity 0

        Entering ->
            svgStyle <| Style.opacity 1

        Blooming ->
            svgStyle <| Style.opacity 1


hillOffset : Int -> Float -> State -> Attribute msg
hillOffset ms offset vis =
    let
        visibleStyles =
            [ Style.transform [ translate 0 offset ]
            , transitionAll 2000 [ delay ms, cubicBezier 0 0 0 1 ]
            ]
    in
    case vis of
        Blooming ->
            svgStyles visibleStyles

        Entering ->
            svgStyles visibleStyles

        Hidden ->
            svgStyles [ Style.transform [ translate 0 800 ] ]


renderFlowers : Int -> Window -> State -> Svg msg
renderFlowers delay window vis =
    case vis of
        Blooming ->
            flowers delay window

        Entering ->
            Svg.g [] []

        Hidden ->
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
    case Window.size window of
        Window.Small ->
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
