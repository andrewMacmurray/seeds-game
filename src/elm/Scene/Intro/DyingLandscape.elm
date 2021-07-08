module Scene.Intro.DyingLandscape exposing
    ( State(..)
    , alive
    , dead
    , hidden
    , leaving
    , view
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Icon.Tree.Elm as Elm
import Element.Icon.Tree.Fir as Fir
import Element.Icon.Tree.Pine as Pine
import Element.Palette as Palette
import Geometry.Hill.Steep as Steep
import Geometry.Shape as Shape exposing (Shape)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Utils.Cycle as Cycle
import Window exposing (Window, vh)



-- Landscape State


type State
    = Hidden
    | Alive
    | Dead
    | Leaving


hidden : State
hidden =
    Hidden


alive : State
alive =
    Alive


dead : State
dead =
    Dead


leaving : State
leaving =
    Leaving



-- View


view : Window -> State -> Svg msg
view window state =
    Shape.fullScreen window
        (shape_
            { state = state
            , colors = toColors state
            , window = window
            }
        )


toColors : State -> Colors
toColors state =
    case state of
        Hidden ->
            greens

        Alive ->
            greens

        Dead ->
            browns

        Leaving ->
            browns



-- Hills


type alias Colors =
    Cycle.Three Colors_


type alias Colors_ =
    { left : Color
    , right : Color
    }


type alias Options_ =
    { window : Window
    , colors : Colors
    , state : State
    }


maxHills : Int
maxHills =
    List.length (sprites Alive)



-- Colors


greens : Colors
greens =
    { one = { left = Palette.green8, right = Palette.green3 }
    , two = { left = Palette.green4, right = Palette.green2 }
    , three = { left = Palette.green1, right = Palette.green6 }
    }


browns : Colors
browns =
    { one = { left = Palette.slate5, right = Palette.brown6 }
    , two = { left = Palette.grey5, right = Palette.slate6 }
    , three = { left = Palette.grey4, right = Palette.brown1 }
    }



-- View


shape_ : Options_ -> Shape msg
shape_ options =
    sprites options.state
        |> List.indexedMap (toHillConfig options)
        |> List.map (toHillPair options)
        |> List.concat
        |> List.reverse
        |> Shape.group
        |> Shape.moveUp 200


sprites : State -> List (Steep.SpriteLayer msg)
sprites state =
    Steep.spriteLayers
        [ Steep.blankLayer
        , ( Steep.sprites
                { inner = Nothing
                , middle = Just (doubleFir 0 state)
                , outer = Nothing
                }
          , Steep.sprites
                { inner = Nothing
                , middle = Just (doubleFir 200 state)
                , outer = Nothing
                }
          )
        , ( Steep.sprites
                { inner = Just (doubleFir 100 state)
                , middle = Just (pine state)
                , outer = Just (singleFir 400 state)
                }
          , Steep.sprites
                { inner = Just (singleFir 500 state)
                , middle = Just (elm state)
                , outer = Just (singleFir 300 state)
                }
          )
        , Steep.blankLayer
        ]


doubleFir : Animation.Millis -> State -> Steep.Sprite msg
doubleFir delay state =
    Steep.behind [ fir_ delay state, fir_ delay state ]


singleFir : Animation.Millis -> State -> Steep.Sprite msg
singleFir delay state =
    Steep.behind [ fir_ delay state ]


elm : State -> Steep.Sprite msg
elm state =
    Steep.inFront [ Elm.alive ]


pine : State -> Steep.Sprite msg
pine state =
    Steep.inFront [ Pine.alive ]


fir_ : Animation.Millis -> State -> Svg msg
fir_ delay state =
    case state of
        Hidden ->
            Fir.alive

        Alive ->
            Fir.alive

        Dead ->
            Fir.dying delay

        Leaving ->
            Fir.dead


cycleColors : Options_ -> Int -> Colors_
cycleColors options =
    Cycle.three options.colors


type alias HillConfig msg =
    { order : Int
    , offset : Float
    , left : Steep.Side msg
    , right : Steep.Side msg
    }


toHillConfig : Options_ -> Int -> Steep.SpriteLayer msg -> HillConfig msg
toHillConfig options i ( left, right ) =
    { order = i
    , offset = 750 - toFloat (i * 180)
    , left =
        { sprites = left
        , color = .left (cycleColors options i)
        }
    , right =
        { sprites = right
        , color = .right (cycleColors options i)
        }
    }


toHillPair : Options_ -> HillConfig msg -> List (Shape msg)
toHillPair options config =
    Steep.hillPair
        { window = options.window
        , offset = toOffset options config
        , left = config.left
        , right = config.right
        , animation = animation options config
        }


toOffset : Options_ -> HillConfig msg -> Float
toOffset options config =
    case options.state of
        Hidden ->
            10000

        _ ->
            config.offset



-- Animate


animation : Options_ -> HillConfig msg -> Maybe Animation
animation options config =
    case options.state of
        Hidden ->
            Nothing

        Alive ->
            Just (appear options config)

        Dead ->
            Nothing

        Leaving ->
            Just (fadeOut config)


appear : Options_ -> HillConfig msg -> Animation
appear options config =
    Animation.fromTo
        { duration = 5000
        , options =
            [ Animation.easeOut
            , Animation.delay (maxHills - (config.order + 1) * 150)
            ]
        }
        [ P.y ((vh options.window / 2) + vh options.window / toFloat (maxHills - config.order)) ]
        [ P.y 0 ]


fadeOut config =
    Animations.fadeOut 500
        [ Animation.delay ((maxHills - config.order) * 350)
        ]



-- Shape
--let
--    hillColor aliveColor deadColor =
--        ifAlive env aliveColor deadColor
--
--    slope =
--        getSlope window
--
--    hillOffset small large =
--        ifNarrow window small large
--
--    ( elements2Left, elements2Right ) =
--        hillElements2 window env
--
--    ( elements3Left, elements3Right ) =
--        hillElements3 window env
--
--    ( elements4Left, elements4Right ) =
--        hillElements4 window env
--in
--Svg.window window
--    [ preserveAspectRatio "none" ]
--    [ Svg.g (hillStyles window state (hillOffset -250 -400) 0)
--        [ Hills.layer window
--            slope
--            ( hillColor "#1D4E34" "#898755", [ transitionFill 0 ], [] )
--            ( hillColor "#19B562" "#866942", [ transitionFill 300 ], [] )
--        ]
--    , Svg.g (hillStyles window state (hillOffset -125 -250) 500)
--        [ Hills.layer window
--            slope
--            ( hillColor "#1D7145" "#7D7E7D", [ transitionFill 600 ], elements2Left )
--            ( hillColor "#1F8D52" "#978A49", [ transitionFill 900 ], elements2Right )
--        ]
--    , Svg.g (hillStyles window state (hillOffset 0 -100) 1000)
--        [ Hills.layer window
--            slope
--            ( hillColor "#2BA765" "#484848", [ transitionFill 1200 ], elements3Left )
--            ( hillColor "#185F39" "#372c1f", [ transitionFill 1500 ], elements3Right )
--        ]
--    , Svg.g (hillStyles window state (hillOffset 125 50) 1000)
--        [ Hills.layer window
--            slope
--            ( hillColor "#1F8D52" "#6e6e4e", [ transitionFill 1200 ], elements4Left )
--            ( hillColor "#19B562" "#817d75", [ transitionFill 1500 ], elements4Right )
--        ]
--    ]
--
--ifAlive : Environment -> a -> a -> a
--ifAlive env a b =
--    case env of
--        Alive ->
--            a
--
--        Dead ->
--            b
--
--
--ifNarrow : Window -> a -> a -> a
--ifNarrow window a b =
--    case Window.width window of
--        Window.Narrow ->
--            a
--
--        _ ->
--            b
--
--
--getSlope : Window -> Float
--getSlope window =
--    case Window.width window of
--        Window.Narrow ->
--            0.65
--
--        _ ->
--            0.5
--
--
--hillElements2 : Window -> Environment -> ( List (Hills.Element msg), List (Hills.Element msg) )
--hillElements2 window env =
--    case Window.width window of
--        Window.Narrow ->
--            ( []
--            , [ Hills.behind 6 4.5 <| scaled 0.9 <| firrTree env 500
--              , Hills.behind 9 4.5 <| scaled 0.9 <| firrTree env 600
--              ]
--            )
--
--        Window.MediumWidth ->
--            ( []
--            , [ Hills.behind 6 6 <| firrTree env 500
--              , Hills.behind 10 6 <| firrTree env 600
--              ]
--            )
--
--        Window.Wide ->
--            ( [ Hills.behind 25 6 <| firrTree env 300
--              , Hills.behind 30 6 <| firrTree env 400
--              ]
--            , [ Hills.behind 20 6 <| firrTree env 500
--              , Hills.behind 25 6 <| firrTree env 600
--              ]
--            )
--
--
--hillElements3 : Window -> Environment -> ( List (Hills.Element msg), List (Hills.Element msg) )
--hillElements3 window env =
--    case Window.width window of
--        Window.Narrow ->
--            ( [ Hills.inFront 4 5 <| scaled 0.8 <| pineTree env 800 ]
--            , [ Hills.inFront 8 2 <| scaled 0.8 <| elmTree env 900 ]
--            )
--
--        Window.MediumWidth ->
--            ( [ Hills.behind 6 8 <| pineTree env 800 ]
--            , [ Hills.inFront 18 5 <| elmTree env 900 ]
--            )
--
--        Window.Wide ->
--            ( [ Hills.behind 6 8 <| pineTree env 800
--              , Hills.inFront 30 7 <| elmTree env 900
--              ]
--            , [ Hills.inFront 35 6 <| pineTree env 600 ]
--            )
--
--
--hillElements4 : Window -> Environment -> ( List (Hills.Element msg), List (Hills.Element msg) )
--hillElements4 window env =
--    case Window.width window of
--        Window.Narrow ->
--            ( [], [] )
--
--        Window.MediumWidth ->
--            ( [ Hills.behind 16 6 <| firrTree env 1000
--              , Hills.behind 20 6 <| firrTree env 1000
--              ]
--            , []
--            )
--
--        Window.Wide ->
--            ( [], [ Hills.behind 5 6 <| firrTree env 1000 ] )
--
--
--hillStyles : Window -> State -> Float -> Int -> List (Attribute msg)
--hillStyles window state offset delay =
--    let
--        transitionTransform =
--            Transition.transform_ 3500
--                [ Transition.delay delay
--                , Transition.easeOut
--                ]
--
--        translateY n =
--            Style.transform [ Transform.translateY n ]
--    in
--    case state of
--        Hidden ->
--            [ translateY <| toFloat window.height / 2
--            , transitionTransform
--            ]
--
--        Entering ->
--            [ translateY offset
--            , transitionTransform
--            ]
--
--        Visible ->
--            [ Style.opacity 1
--            , translateY offset
--            ]
--
--        Leaving ->
--            [ Style.opacity 0
--            , Transition.opacity_ 400 [ Transition.linear, Transition.delay delay ]
--            , translateY offset
--            ]
--
--transitionFill : Int -> Attribute msg
--transitionFill delayMs =
--    Transition.fill_ 500 [ Transition.delay delayMs, Transition.linear ]
--
--
--treeColor left right env =
--    ifAlive env ( left, right ) deadTreeColors
--
--
--deadTreeColors : ( String, String )
--deadTreeColors =
--    ( "#C09E73", "#FFCD93" )
