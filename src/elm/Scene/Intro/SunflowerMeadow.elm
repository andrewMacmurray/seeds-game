module Scene.Intro.SunflowerMeadow exposing
    ( State(..)
    , view
    )

import Element.Animations as Animations
import Element.Flower.Sunflower as Sunflower
import Element.Legacy.Landscape.RollingHills as Hills
import Html exposing (Html, div)
import Simple.Animation as Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Html.Style as Html
import Utils.Svg as Svg exposing (..)
import Utils.Svg.Style as Style
import Utils.Svg.Transition as Transition
import Utils.Transform as Transform
import Window exposing (Window)


type State
    = Blooming
    | Entering
    | Hidden


view : Window -> State -> Html msg
view window state =
    div []
        [ div
            (Html.center
                [ Html.width 200
                , Html.zIndex 5
                , Html.relative
                ]
            )
            [ Sunflower.animated 0 ]
        , div
            [ Html.fixed
            , Html.top 0
            , Html.fullWidth
            ]
            [ hills window state ]
        ]


hills window state =
    Svg.window window
        []
        [ Hills.doubleLayer window ( "#9ae9af", [] ) ( "#46cda2", [] ) |> offsetBy window state -500 1500
        , Hills.doubleLayer window ( "#22c37c", [] ) ( "#225941", [] ) |> offsetBy window state -400 1200
        , Hills.doubleLayer window ( "#27af76", [] ) ( "#339576", [] ) |> offsetBy window state -300 1000
        , Hills.doubleLayer window ( "#62DE83", [] ) ( "#15674D", [] ) |> offsetBy window state -200 800
        , Hills.doubleLayer window ( "#22c37c", flowersLeft window state 500 ) ( "#225941", flowersRight window state 500 )
            |> offsetBy window state -100 600
        , Hills.doubleLayer window ( "#277854", flowersLeft window state 250 ) ( "#17A667", flowersRight window state 250 )
            |> offsetBy window state 0 400
        , Hills.doubleLayer window ( "#2cd99b", flowersLeft window state 0 ) ( "#339576", flowersRight window state 0 )
            |> offsetBy window state 100 200
        , Hills.doubleLayer window ( "#169a63", [] ) ( "#15674D", [] ) |> offsetBy window state 200 0
        ]


offsetBy : Window -> State -> Float -> Int -> Svg msg -> Svg msg
offsetBy window state offset delay el =
    Svg.g [ offsetStyles window state offset delay ] [ el ]


offsetStyles : Window -> State -> Float -> Int -> Svg.Attribute msg
offsetStyles window state offset delay =
    let
        translateY n =
            Style.transform [ Transform.translateY n ]

        visibleStyles =
            Style.svg
                [ translateY offset
                , Transition.transition "transform" 2000 [ Transition.cubicBezier 0 0 0 1, Transition.delay delay ]
                ]
    in
    case state of
        Hidden ->
            Style.svg
                [ translateY (toFloat (window.height // 2))
                ]

        Entering ->
            visibleStyles

        Blooming ->
            visibleStyles


flowersLeft : Window -> State -> Int -> List (Hills.Element msg)
flowersLeft window state delay =
    let
        range =
            windowRange window
    in
    [ Hills.element (range 14 18 23) 0 <| scaled (range 0.6 1 1.2) <| sunflower window state delay
    , Hills.element (range 9 13.5 18) 0 <| scaled (range 0.5 0.8 1) <| sunflower window state (delay + 150)
    , Hills.element (range 5 9.5 13) 0 <| scaled (range 0.4 0.6 0.8) <| sunflower window state (delay + 300)
    ]


flowersRight : Window -> State -> Int -> List (Hills.Element msg)
flowersRight window state delay =
    let
        range =
            windowRange window
    in
    [ Hills.element (range -14 -18 -23) 0 <| scaled (range 0.6 1 1.2) <| sunflower window state delay
    , Hills.element (range -9 -13.5 -18) 0 <| scaled (range 0.5 0.8 1) <| sunflower window state (delay + 150)
    , Hills.element (range -5 -9.5 -13) 0 <| scaled (range 0.4 0.6 0.8) <| sunflower window state (delay + 300)
    ]


windowRange window narrow medium wide =
    case Window.width window of
        Window.Narrow ->
            narrow

        Window.MediumWidth ->
            medium

        Window.Wide ->
            wide


sunflower : Window -> State -> Int -> Svg msg
sunflower window state delay =
    case state of
        Blooming ->
            Svg.svg
                [ viewBox_ 0 0 30 30
                , width_ 60
                , height_ 60
                ]
                [ animateSunflower window delay ]
                |> translated -30 -30

        _ ->
            Svg.g [] []


animateSunflower : Window -> Int -> Svg msg
animateSunflower window delay =
    case Window.size window of
        Window.Small ->
            Animated.g (fadeIn delay) [] [ Sunflower.static ]

        _ ->
            Sunflower.animated delay


fadeIn : Int -> Animation
fadeIn delay =
    Animations.fadeIn 1000
        [ Animation.linear
        , Animation.delay ((delay * 150) // 100)
        ]
