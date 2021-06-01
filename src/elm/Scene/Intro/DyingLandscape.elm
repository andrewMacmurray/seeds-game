module Scene.Intro.DyingLandscape exposing
    ( Environment(..)
    , State(..)
    , view
    )

import Css.Style as Style exposing (Style)
import Css.Transform as Transform
import Css.Transition as Transition exposing (delay, linear, transition)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg exposing (..)
import View.Landscape.SteepHills as Hills
import Window exposing (Window)



-- Landscape State


type Environment
    = Alive
    | Dead


type State
    = Entering
    | Visible
    | Leaving
    | Hidden



-- View


view : Window -> Environment -> State -> Svg msg
view window env state =
    let
        hillColor aliveColor deadColor =
            ifAlive env aliveColor deadColor

        slope =
            getSlope window

        hillOffset small large =
            ifNarrow window small large

        ( elements2Left, elements2Right ) =
            hillElements2 window env

        ( elements3Left, elements3Right ) =
            hillElements3 window env

        ( elements4Left, elements4Right ) =
            hillElements4 window env
    in
    Svg.window window
        [ preserveAspectRatio "none" ]
        [ Svg.g [ hillStyles window state (hillOffset -250 -400) 0 ]
            [ Hills.layer window
                slope
                ( hillColor "#1D4E34" "#898755", [ transitionFill 0 ], [] )
                ( hillColor "#19B562" "#866942", [ transitionFill 300 ], [] )
            ]
        , Svg.g [ hillStyles window state (hillOffset -125 -250) 500 ]
            [ Hills.layer window
                slope
                ( hillColor "#1D7145" "#7D7E7D", [ transitionFill 600 ], elements2Left )
                ( hillColor "#1F8D52" "#978A49", [ transitionFill 900 ], elements2Right )
            ]
        , Svg.g [ hillStyles window state (hillOffset 0 -100) 1000 ]
            [ Hills.layer window
                slope
                ( hillColor "#2BA765" "#484848", [ transitionFill 1200 ], elements3Left )
                ( hillColor "#185F39" "#372c1f", [ transitionFill 1500 ], elements3Right )
            ]
        , Svg.g [ hillStyles window state (hillOffset 125 50) 1000 ]
            [ Hills.layer window
                slope
                ( hillColor "#1F8D52" "#6e6e4e", [ transitionFill 1200 ], elements4Left )
                ( hillColor "#19B562" "#817d75", [ transitionFill 1500 ], elements4Right )
            ]
        ]


ifAlive : Environment -> a -> a -> a
ifAlive env a b =
    case env of
        Alive ->
            a

        Dead ->
            b


ifNarrow : Window -> a -> a -> a
ifNarrow window a b =
    case Window.width window of
        Window.Narrow ->
            a

        _ ->
            b


getSlope : Window -> Float
getSlope window =
    case Window.width window of
        Window.Narrow ->
            0.65

        _ ->
            0.5


hillElements2 : Window -> Environment -> ( List (Hills.Element msg), List (Hills.Element msg) )
hillElements2 window env =
    case Window.width window of
        Window.Narrow ->
            ( []
            , [ Hills.behind 6 4.5 <| scaled 0.9 <| firrTree env 500
              , Hills.behind 9 4.5 <| scaled 0.9 <| firrTree env 600
              ]
            )

        Window.MediumWidth ->
            ( []
            , [ Hills.behind 6 6 <| firrTree env 500
              , Hills.behind 10 6 <| firrTree env 600
              ]
            )

        Window.Wide ->
            ( [ Hills.behind 25 6 <| firrTree env 300
              , Hills.behind 30 6 <| firrTree env 400
              ]
            , [ Hills.behind 20 6 <| firrTree env 500
              , Hills.behind 25 6 <| firrTree env 600
              ]
            )


hillElements3 : Window -> Environment -> ( List (Hills.Element msg), List (Hills.Element msg) )
hillElements3 window env =
    case Window.width window of
        Window.Narrow ->
            ( [ Hills.inFront 4 5 <| scaled 0.8 <| pineTree env 800 ]
            , [ Hills.inFront 8 2 <| scaled 0.8 <| elmTree env 900 ]
            )

        Window.MediumWidth ->
            ( [ Hills.behind 6 8 <| pineTree env 800 ]
            , [ Hills.inFront 18 5 <| elmTree env 900 ]
            )

        Window.Wide ->
            ( [ Hills.behind 6 8 <| pineTree env 800
              , Hills.inFront 30 7 <| elmTree env 900
              ]
            , [ Hills.inFront 35 6 <| pineTree env 600 ]
            )


hillElements4 : Window -> Environment -> ( List (Hills.Element msg), List (Hills.Element msg) )
hillElements4 window env =
    case Window.width window of
        Window.Narrow ->
            ( [], [] )

        Window.MediumWidth ->
            ( [ Hills.behind 16 6 <| firrTree env 1000
              , Hills.behind 20 6 <| firrTree env 1000
              ]
            , []
            )

        Window.Wide ->
            ( [], [ Hills.behind 5 6 <| firrTree env 1000 ] )


hillStyles : Window -> State -> Float -> Int -> Attribute msg
hillStyles window state offset delay =
    let
        transitionTransform =
            Transition.transition "transform" 3500 [ Transition.delay delay, Transition.easeOut ]

        translateY n =
            Style.transform [ Transform.translateY n ]
    in
    case state of
        Hidden ->
            Style.svgStyle
                [ translateY <| toFloat window.height / 2
                , transitionTransform
                ]

        Entering ->
            Style.svgStyle
                [ translateY offset
                , transitionTransform
                ]

        Visible ->
            Style.svgStyle
                [ Style.opacity 1
                , translateY offset
                ]

        Leaving ->
            Style.svgStyle
                [ Style.opacity 0
                , Transition.transition "opacity" 400 [ Transition.linear, Transition.delay delay ]
                , translateY offset
                ]


firrTree : Environment -> Int -> Svg msg
firrTree env delay =
    let
        animateFill =
            transitionFillStyle delay

        ( leftColor, rightColor ) =
            treeColor "#24AC4B" "#95EDB3" env
    in
    Svg.svg [ width_ 4, height_ 10, viewBox_ 0 0 40 100 ]
        [ Svg.g [ fill "none", fillRule "evenodd" ]
            [ Svg.path [ fill "#6D4D2D", d "M12.2 41h6.6V75h-6.6z" ] []
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill, d "M15.6.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8V.4z", fill leftColor ] []
                , Svg.path [ animateFill, d "M.8 33.2C.8 21 14.7 1.6 15.5.4V48C7.4 48 .8 41.4.8 33.2z", fill rightColor ] []
                ]
            ]
        ]


elmTree : Environment -> Int -> Svg msg
elmTree env delay =
    let
        animateFill staggerDelay =
            transitionFillStyle <| delay + staggerDelay

        ( leftColor, rightColor ) =
            treeColor "#32B559" "#4CE483" env
    in
    Svg.svg [ width_ 11, height_ 17, viewBox_ 0 0 80 150 ]
        [ Svg.g [ fill "none", fillRule "evenodd" ]
            [ Svg.path [ fill "#6D4D2D", d "M28.3 78.4h6.2v35.5h-6.2z" ] []
            , Svg.path [ fill "#6D4D2D", d "M9.6 61.2l3.4-3.5 21.3 20.6-3.4 3.5z" ] []
            , Svg.path [ fill "#6D4D2D", d "M67.3 47.3L64 44 28 78.5l3.4 3.4z" ] []
            , Svg.path [ fill "#6D4D2D", d "M15.6 24.6l3.5-3.6 35.8 34.6-3.4 3.6z" ] []
            , Svg.path [ animateFill 50, d "M65 25v25h-.5a12.5 12.5 0 1 1 .5-25z", fill leftColor ] []
            , Svg.path [ animateFill 50, d "M64 25v25h.5a12.5 12.5 0 1 0-.5-25z", fill rightColor ] []
            , Svg.path [ animateFill 100, d "M19 0v25h-.5A12.5 12.5 0 1 1 19 0z", fill leftColor ] []
            , Svg.path [ animateFill 100, d "M18 0v25h.5A12.5 12.5 0 1 0 18 0z", fill rightColor ] []
            , Svg.path [ animateFill 150, d "M13 38v25h-.5a12.5 12.5 0 1 1 .5-25z", fill leftColor ] []
            , Svg.path [ animateFill 150, d "M12 38v25h.5a12.5 12.5 0 1 0-.5-25z", fill rightColor ] []
            ]
        ]


pineTree : Environment -> Int -> Svg msg
pineTree env delay =
    let
        animateFill staggerDelay =
            transitionFillStyle <| delay + staggerDelay

        ( leftColor, rightColor ) =
            treeColor "#95EDB3" "#24AC4B" env
    in
    Svg.svg [ width_ 11, height_ 13, viewBox_ 0 0 80 100 ]
        [ Svg.g [ fill "none", fillRule "evenodd" ]
            [ Svg.path [ fill "#453321", d "M34.1 51.8h6.8v36.7h-6.8z" ] []
            , Svg.path [ fill "#453321", d "M12.7 33.2l4.8-4.8L41 52l-4.8 4.8z" ] []
            , Svg.path [ fill "#453321", d "M62.5 33.2l-4.9-4.8L34 52l4.8 4.8z" ] []
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill 0, d "M10.4 4.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V4.7z", fill leftColor ] []
                , Svg.path [ animateFill 0, d "M.7 26.3c0-8 9.1-20.8 9.7-21.6V36a9.7 9.7 0 0 1-9.7-9.7z", fill rightColor ] []
                ]
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill 150, d "M37.5 18s9.7 13.5 9.7 21.7c0 5.4-4.3 9.7-9.7 9.7V18.1z", fill leftColor ] []
                , Svg.path [ animateFill 150, d "M27.8 39.7c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z", fill rightColor ] []
                ]
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill 300, d "M37.5 0s9.7 13.4 9.7 21.6c0 5.4-4.3 9.8-9.7 9.8V0z", fill leftColor ] []
                , Svg.path [ animateFill 300, d "M27.8 21.6c0-8 9.1-20.7 9.7-21.5v31.3a9.7 9.7 0 0 1-9.7-9.8z", fill rightColor ] []
                ]
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill 450, d "M51.3 11.9S61 25.3 61 33.5c0 5.4-4.3 9.7-9.7 9.7V12z", fill leftColor ] []
                , Svg.path [ animateFill 450, d "M41.7 33.5c0-8 9-20.8 9.6-21.6v31.3a9.7 9.7 0 0 1-9.6-9.7z", fill rightColor ] []
                ]
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill 550, d "M22.7 11.9s9.7 13.4 9.7 21.6c0 5.4-4.4 9.7-9.7 9.7V12z", fill leftColor ] []
                , Svg.path [ animateFill 550, d "M13 33.5c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z", fill rightColor ] []
                ]
            , Svg.g [ fillRule "nonzero" ]
                [ Svg.path [ animateFill 650, d "M64.6 4.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V4.7z", fill leftColor ] []
                , Svg.path [ animateFill 650, d "M55 26.3c0-8 9-20.8 9.6-21.6V36a9.7 9.7 0 0 1-9.6-9.7z", fill rightColor ] []
                ]
            ]
        ]


transitionFillStyle : Int -> Attribute msg
transitionFillStyle delayMs =
    Style.svgStyle [ transitionFill delayMs ]


transitionFill : Int -> Style
transitionFill delayMs =
    transition "fill" 500 [ delay delayMs, linear ]


treeColor left right env =
    ifAlive env ( left, right ) deadTreeColors


deadTreeColors : ( String, String )
deadTreeColors =
    ( "#C09E73", "#FFCD93" )
