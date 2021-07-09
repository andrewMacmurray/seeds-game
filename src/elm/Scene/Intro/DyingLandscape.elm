module Scene.Intro.DyingLandscape exposing
    ( Environment(..)
    , State(..)
    , view
    )

import Element.Icon.Tree.Elm as Elm
import Element.Icon.Tree.Fir as Fir
import Element.Legacy.Landscape.SteepHills as Hills
import Simple.Transition as Transition
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Utils.Style as Style
import Utils.Svg as Svg exposing (..)
import Utils.Transform as Transform
import Utils.Transition as Transition
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
            ifAlive aliveColor deadColor env

        slope =
            getSlope window

        hillOffset small large =
            Window.whenNarrow small large window

        ( sprites2Left, sprites2Right ) =
            hillSprites2 window env

        ( sprites3Left, sprites3Right ) =
            hillSprites3 window env

        ( sprites4Left, sprites4Right ) =
            hillSprites4 window env
    in
    Svg.window window
        [ preserveAspectRatio "none" ]
        [ Svg.g (hillStyles window state (hillOffset -250 -400) 0)
            [ Hills.layer window
                slope
                ( hillColor "#1D4E34" "#898755", [ transitionFill 0 ], [] )
                ( hillColor "#19B562" "#866942", [ transitionFill 300 ], [] )
            ]
        , Svg.g (hillStyles window state (hillOffset -125 -250) 500)
            [ Hills.layer window
                slope
                ( hillColor "#1D7145" "#7D7E7D", [ transitionFill 600 ], sprites2Left )
                ( hillColor "#1F8D52" "#978A49", [ transitionFill 900 ], sprites2Right )
            ]
        , Svg.g (hillStyles window state (hillOffset 0 -100) 1000)
            [ Hills.layer window
                slope
                ( hillColor "#2BA765" "#484848", [ transitionFill 1200 ], sprites3Left )
                ( hillColor "#185F39" "#372c1f", [ transitionFill 1500 ], sprites3Right )
            ]
        , Svg.g (hillStyles window state (hillOffset 125 50) 1000)
            [ Hills.layer window
                slope
                ( hillColor "#1F8D52" "#6e6e4e", [ transitionFill 1200 ], sprites4Left )
                ( hillColor "#19B562" "#817d75", [ transitionFill 1500 ], sprites4Right )
            ]
        ]


ifAlive : a -> a -> Environment -> a
ifAlive a b env =
    case env of
        Alive ->
            a

        Dead ->
            b


getSlope : Window -> Float
getSlope =
    Window.whenNarrow 0.65 0.5


hillSprites2 : Window -> Environment -> ( List (Hills.Sprite msg), List (Hills.Sprite msg) )
hillSprites2 window env =
    case Window.width window of
        Window.Narrow ->
            ( []
            , [ Hills.behind 6 4.5 (scaled 0.9 (firTree env 500))
              , Hills.behind 9 4.5 (scaled 0.9 (firTree env 600))
              ]
            )

        Window.MediumWidth ->
            ( []
            , [ Hills.behind 6 6 (firTree env 500)
              , Hills.behind 10 6 (firTree env 600)
              ]
            )

        Window.Wide ->
            ( [ Hills.behind 25 6 (firTree env 300)
              , Hills.behind 30 6 (firTree env 400)
              ]
            , [ Hills.behind 20 6 (firTree env 500)
              , Hills.behind 25 6 (firTree env 600)
              ]
            )


hillSprites3 : Window -> Environment -> ( List (Hills.Sprite msg), List (Hills.Sprite msg) )
hillSprites3 window env =
    case Window.width window of
        Window.Narrow ->
            ( [ Hills.inFront 4 5 (scaled 0.8 (pineTree env 800)) ]
            , [ Hills.inFront 8 2 (scaled 0.8 (elmTree env 900)) ]
            )

        Window.MediumWidth ->
            ( [ Hills.behind 6 8 (pineTree env 800) ]
            , [ Hills.inFront 18 5 (elmTree env 900) ]
            )

        Window.Wide ->
            ( [ Hills.behind 6 8 (pineTree env 800)
              , Hills.inFront 30 7 (elmTree env 900)
              ]
            , [ Hills.inFront 35 6 (pineTree env 600) ]
            )


hillSprites4 : Window -> Environment -> ( List (Hills.Sprite msg), List (Hills.Sprite msg) )
hillSprites4 window env =
    case Window.width window of
        Window.Narrow ->
            ( [], [] )

        Window.MediumWidth ->
            ( [ Hills.behind 16 6 (firTree env 1000)
              , Hills.behind 20 6 (firTree env 1000)
              ]
            , []
            )

        Window.Wide ->
            ( [], [ Hills.behind 5 6 (firTree env 1000) ] )


hillStyles : Window -> State -> Float -> Int -> List (Attribute msg)
hillStyles window state offset delay =
    let
        transitionTransform =
            Transition.transform_ 3500
                [ Transition.delay delay
                , Transition.easeOut
                ]

        translateY n =
            Style.transform [ Transform.translateY n ]
    in
    case state of
        Hidden ->
            [ translateY (toFloat window.height / 2)
            , transitionTransform
            ]

        Entering ->
            [ translateY offset
            , transitionTransform
            ]

        Visible ->
            [ Style.opacity 1
            , translateY offset
            ]

        Leaving ->
            [ Style.opacity 0
            , Transition.opacity_ 400 [ Transition.linear, Transition.delay delay ]
            , translateY offset
            ]


firTree : Environment -> Int -> Svg msg
firTree env delay =
    Fir.tree
        { colors = firColors env
        , delay = delay
        }


firColors : Environment -> Fir.Colors
firColors =
    ifAlive Fir.alive Fir.dead


elmTree : Environment -> Int -> Svg msg
elmTree env delay =
    Elm.tree
        { colors = elmColors env
        , delay = delay
        }


elmColors : Environment -> Elm.Colors
elmColors =
    ifAlive Elm.alive Elm.dead


pineTree : Environment -> Int -> Svg msg
pineTree env delay =
    let
        animateFill staggerDelay =
            transitionFill (delay + staggerDelay)

        ( leftColor, rightColor ) =
            treeColor "#95EDB3" "#24AC4B" env
    in
    Svg.svg [ width_ 11, height_ 13, viewBox_ 0 0 80 100 ]
        [ Svg.path [ fill "#453321", d "M34.1 51.8h6.8v36.7h-6.8z" ] []
        , Svg.path [ fill "#453321", d "M12.7 33.2l4.8-4.8L41 52l-4.8 4.8z" ] []
        , Svg.path [ fill "#453321", d "M62.5 33.2l-4.9-4.8L34 52l4.8 4.8z" ] []
        , Svg.path [ animateFill 0, d "M10.4 4.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V4.7z", fill leftColor ] []
        , Svg.path [ animateFill 0, d "M.7 26.3c0-8 9.1-20.8 9.7-21.6V36a9.7 9.7 0 0 1-9.7-9.7z", fill rightColor ] []
        , Svg.path [ animateFill 150, d "M37.5 18s9.7 13.5 9.7 21.7c0 5.4-4.3 9.7-9.7 9.7V18.1z", fill leftColor ] []
        , Svg.path [ animateFill 150, d "M27.8 39.7c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z", fill rightColor ] []
        , Svg.path [ animateFill 300, d "M37.5 0s9.7 13.4 9.7 21.6c0 5.4-4.3 9.8-9.7 9.8V0z", fill leftColor ] []
        , Svg.path [ animateFill 300, d "M27.8 21.6c0-8 9.1-20.7 9.7-21.5v31.3a9.7 9.7 0 0 1-9.7-9.8z", fill rightColor ] []
        , Svg.path [ animateFill 450, d "M51.3 11.9S61 25.3 61 33.5c0 5.4-4.3 9.7-9.7 9.7V12z", fill leftColor ] []
        , Svg.path [ animateFill 450, d "M41.7 33.5c0-8 9-20.8 9.6-21.6v31.3a9.7 9.7 0 0 1-9.6-9.7z", fill rightColor ] []
        , Svg.path [ animateFill 550, d "M22.7 11.9s9.7 13.4 9.7 21.6c0 5.4-4.4 9.7-9.7 9.7V12z", fill leftColor ] []
        , Svg.path [ animateFill 550, d "M13 33.5c0-8 9.1-20.8 9.7-21.6v31.3a9.7 9.7 0 0 1-9.7-9.7z", fill rightColor ] []
        , Svg.path [ animateFill 650, d "M64.6 4.7s9.7 13.4 9.7 21.6c0 5.4-4.3 9.7-9.7 9.7V4.7z", fill leftColor ] []
        , Svg.path [ animateFill 650, d "M55 26.3c0-8 9-20.8 9.6-21.6V36a9.7 9.7 0 0 1-9.6-9.7z", fill rightColor ] []
        ]


transitionFill : Int -> Attribute msg
transitionFill delayMs =
    Transition.fill_ 500 [ Transition.delay delayMs, Transition.linear ]


treeColor : String -> String -> Environment -> ( String, String )
treeColor left right =
    ifAlive ( left, right ) deadTreeColors


deadTreeColors : ( String, String )
deadTreeColors =
    ( "#C09E73", "#FFCD93" )
