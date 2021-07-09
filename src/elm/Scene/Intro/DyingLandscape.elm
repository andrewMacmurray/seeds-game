module Scene.Intro.DyingLandscape exposing
    ( Environment(..)
    , State
    , Visibility(..)
    , dead
    , hidden
    , leaving
    , view
    , visible
    )

import Element.Icon.Tree.Elm as Elm
import Element.Icon.Tree.Fir as Fir
import Element.Icon.Tree.Pine as Pine
import Element.Legacy.Landscape.SteepHills as Hills
import Simple.Transition as Transition
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Utils.Style as Style
import Utils.Svg as Svg exposing (..)
import Utils.Transform as Transform
import Utils.Transition as Transition
import Window exposing (Window)



-- Dying Landscape


type alias State =
    { environment : Environment
    , visibility : Visibility
    }


type Environment
    = Alive
    | Dead


type Visibility
    = Entering
    | Visible
    | Leaving
    | Hidden



-- States


hidden : State
hidden =
    { environment = Alive
    , visibility = Hidden
    }


visible : State
visible =
    { environment = Alive
    , visibility = Entering
    }


dead : State
dead =
    { environment = Dead
    , visibility = Visible
    }


leaving : State
leaving =
    { environment = Dead
    , visibility = Leaving
    }



-- View


view : Window -> State -> Svg msg
view window { environment, visibility } =
    let
        hillColor aliveColor deadColor =
            ifAlive aliveColor deadColor environment

        slope =
            getSlope window

        hillOffset small large =
            Window.whenNarrow small large window

        ( sprites2Left, sprites2Right ) =
            hillSprites2 window environment

        ( sprites3Left, sprites3Right ) =
            hillSprites3 window environment

        ( sprites4Left, sprites4Right ) =
            hillSprites4 window environment
    in
    Svg.window window
        [ preserveAspectRatio "none" ]
        [ Svg.g (hillStyles window visibility (hillOffset -250 -400) 0)
            [ Hills.layer window
                slope
                ( hillColor "#1D4E34" "#898755", [ transitionFill 0 ], [] )
                ( hillColor "#19B562" "#866942", [ transitionFill 300 ], [] )
            ]
        , Svg.g (hillStyles window visibility (hillOffset -125 -250) 500)
            [ Hills.layer window
                slope
                ( hillColor "#1D7145" "#7D7E7D", [ transitionFill 600 ], sprites2Left )
                ( hillColor "#1F8D52" "#978A49", [ transitionFill 900 ], sprites2Right )
            ]
        , Svg.g (hillStyles window visibility (hillOffset 0 -100) 1000)
            [ Hills.layer window
                slope
                ( hillColor "#2BA765" "#484848", [ transitionFill 1200 ], sprites3Left )
                ( hillColor "#185F39" "#372c1f", [ transitionFill 1500 ], sprites3Right )
            ]
        , Svg.g (hillStyles window visibility (hillOffset 125 50) 1000)
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


hillStyles : Window -> Visibility -> Float -> Int -> List (Attribute msg)
hillStyles window visibility offset delay =
    let
        transitionTransform =
            Transition.transform_ 3500
                [ Transition.delay delay
                , Transition.easeOut
                ]

        translateY n =
            Style.transform [ Transform.translateY n ]
    in
    case visibility of
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



-- Sprites


firTree : Environment -> Transition.Millis -> Svg msg
firTree env delay =
    Fir.tree
        { colors = ifAlive Fir.alive Fir.dead env
        , delay = delay
        }


elmTree : Environment -> Transition.Millis -> Svg msg
elmTree env delay =
    Elm.tree
        { colors = ifAlive Elm.alive Elm.dead env
        , delay = delay
        }


pineTree : Environment -> Transition.Millis -> Svg msg
pineTree env delay =
    Pine.tree
        { colors = ifAlive Pine.alive Pine.dead env
        , delay = delay
        }


transitionFill : Transition.Millis -> Attribute msg
transitionFill delayMs =
    Transition.fill_ 500
        [ Transition.delay delayMs
        , Transition.linear
        ]
