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
        |> adjustOffset options


adjustOffset : Options_ -> Shape msg -> Shape msg
adjustOffset options =
    case options.state of
        Hidden ->
            Shape.moveUp pageOffset

        Alive ->
            Shape.moveUp pageOffset

        Dead ->
            Shape.moveUp (pageOffset - animateToOffset)

        Leaving ->
            Shape.moveUp (pageOffset - animateToOffset)


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
        [ P.y (bottomOffset options config) ]
        [ P.y animateToOffset ]


bottomOffset : Options_ -> HillConfig msg -> Float
bottomOffset options config =
    (vh options.window / 2) + (vh options.window / toFloat (maxHills - config.order))


fadeOut : HillConfig msg -> Animation
fadeOut config =
    Animations.fadeOut 500
        [ Animation.delay ((maxHills - config.order) * 350)
        ]



-- Constants


animateToOffset : number
animateToOffset =
    100


pageOffset : number
pageOffset =
    200
