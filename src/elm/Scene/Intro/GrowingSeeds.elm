module Scene.Intro.GrowingSeeds exposing
    ( State(..)
    , view
    )

import Element exposing (..)
import Element.Animation.Bounce as Bounce
import Element.Scale as Scale
import Element.Seed as Seed
import Scene.Level.Board.Tile.Scale as Scale
import Seed exposing (Seed(..))
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Utils.Animated as Animated
import Utils.Element as Element
import Utils.Transition as Transition
import Window exposing (Window)



-- Growing Seeds


type State
    = Entering
    | Leaving



-- View


view : Window -> State -> Element msg
view window state =
    row
        [ centerX
        , spacing -Scale.extraSmall
        , moveUp 20
        ]
        [ sideSeeds window state (List.reverse (seedsLeft window))
        , viewMainSeed window state
        , sideSeeds window state (seedsRight window)
        ]


viewMainSeed : Window -> State -> Element msg
viewMainSeed window state =
    case state of
        Leaving ->
            Animated.el slideDownScaleOut [] (staticSeed window mainSeed)

        Entering ->
            growingSeed window mainSeed


slideDownScaleOut : Animation
slideDownScaleOut =
    Animation.steps
        { startAt = [ P.y 0, P.scale 1 ]
        , options = [ Animation.delay 500, Animation.easeInOutBack ]
        }
        [ Animation.step 1000 [ P.y 50, P.scale 1 ]
        , Animation.step 750 [ P.y 50, P.scale 0 ]
        ]


sideSeeds : Window -> State -> List GrowingSeed -> Element msg
sideSeeds window state seeds =
    row
        [ Transition.alpha 1000
        , Element.visibleIf (isEntering state)
        , spacing -Scale.extraSmall
        ]
        (List.map (growingSeed window) seeds)


isEntering : State -> Bool
isEntering state =
    case state of
        Entering ->
            True

        Leaving ->
            False


growingSeed : Window -> GrowingSeed -> Element msg
growingSeed window seed =
    Animated.el (bulgeFade seed)
        [ Element.originBottom
        , alignBottom
        ]
        (staticSeed window seed)


staticSeed : Window -> GrowingSeed -> Element msg
staticSeed window seed =
    Seed.view (seedSize window seed) seed.seed


seedSize : Window -> GrowingSeed -> Seed.Options
seedSize window seed =
    Seed.size (round (75 * seed.scale * Scale.factor window))


bulgeFade : GrowingSeed -> Animation
bulgeFade seed =
    Bounce.animation
        { options = [ Animation.delay (seed.order * 100) ]
        , duration = 1800
        , property = P.scale
        , bounce = Bounce.springy
        , from = 0
        , to = 1
        }


type alias GrowingSeed =
    { order : Int
    , seed : Seed
    , scale : Float
    }


mainSeed : GrowingSeed
mainSeed =
    { order = 0
    , seed = Sunflower
    , scale = 1.1
    }


seedsLeft : Window -> List GrowingSeed
seedsLeft window =
    case Window.size window of
        Window.Small ->
            [ { order = 3, seed = Marigold, scale = 0.7 }
            , { order = 5, seed = Chrysanthemum, scale = 0.5 }
            , { order = 1, seed = Rose, scale = 0.8 }
            , { order = 7, seed = Lupin, scale = 0.5 }
            ]

        _ ->
            [ { order = 3, seed = Marigold, scale = 0.7 }
            , { order = 9, seed = Chrysanthemum, scale = 0.5 }
            , { order = 7, seed = Rose, scale = 0.8 }
            , { order = 1, seed = Lupin, scale = 1 }
            , { order = 5, seed = Marigold, scale = 0.6 }
            ]


seedsRight : Window -> List GrowingSeed
seedsRight window =
    case Window.size window of
        Window.Small ->
            [ { order = 4, seed = Chrysanthemum, scale = 0.6 }
            , { order = 6, seed = Marigold, scale = 0.7 }
            , { order = 2, seed = Sunflower, scale = 0.5 }
            , { order = 8, seed = Lupin, scale = 0.5 }
            ]

        _ ->
            [ { order = 10, seed = Chrysanthemum, scale = 0.6 }
            , { order = 2, seed = Marigold, scale = 0.7 }
            , { order = 8, seed = Sunflower, scale = 0.5 }
            , { order = 6, seed = Rose, scale = 1 }
            , { order = 4, seed = Lupin, scale = 0.8 }
            ]
