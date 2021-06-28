module Element.Flower.Cornflower exposing
    ( animated
    , static
    )

import Element.Animation.Bounce as Bounce
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Svg as Svg exposing (..)



-- Static


static : Svg msg
static =
    Svg.svg [ viewBox_ 0 0 vbWidth vbHeight ]
        (List.concat
            [ staticPetals largePetals
            , staticPetals smallPetals
            ]
        )



-- Animated


animated : Int -> Svg msg
animated delay =
    Svg.svg [ viewBox_ 0 0 vbWidth vbHeight, width "100%" ]
        (List.concat
            [ animatePetals delay largePetals
            , animatePetals (delay + 750) smallPetals
            ]
        )



-- Internal


staticPetals : List (List (Svg.Attribute msg)) -> List (Svg msg)
staticPetals =
    List.map (\p -> Svg.path p [])


animatePetals : Animation.Millis -> List (List (Svg.Attribute msg)) -> List (Svg msg)
animatePetals =
    List.indexedMap << animatePetal


animatePetal : Animation.Millis -> Int -> List (Svg.Attribute msg) -> Svg msg
animatePetal delay i petal =
    Animated.path (bloom delay i) (style Svg.originCenter_ :: petal) []


bloom : Animation.Millis -> Int -> Animation
bloom delay i =
    Bounce.animation
        { options = [ Animation.delay (i * 50 + delay) ]
        , duration = 1000
        , property = P.scale
        , from = 0
        , to = 1
        , bounce =
            { stiffness = 1.4
            , bounces = 6
            }
        }


smallPetals : List (List (Svg.Attribute msg))
smallPetals =
    [ [ d "M96 100.3c-1.4.5-3.6 3-6.2 8.3-2.5 5-3.3 11-2.4 11.5 1 .5 5-3.3 8.2-8.4 4.3-6.8 4-8.9 3.7-10-.5-1.7-1.8-2-3.3-1.4z", fill "#d4f5f9" ]
    , [ d "M96.3 101.4c-1 1.1-1.6 4.4-1.2 10.4.3 5.5 2.6 11.1 3.7 11 1 0 2.6-5.3 2.8-11.2.4-8.1-.9-9.8-1.7-10.6-1.3-1.2-2.5-.8-3.6.4z", fill "#c1d9ff" ]
    , [ d "M96.3 99.2c-1.4-.3-4.6.8-9.5 4-4.7 3.2-8.4 7.9-7.8 8.8.5 1 6-.4 11.2-3.2 7.1-3.7 8-5.6 8.3-6.8.3-1.7-.6-2.5-2.2-2.8z", fill "#86caea" ]
    , [ d "M97.2 98.3c-1.1-1-4.4-1.6-10.4-1.2-5.6.4-11.1 2.6-11.1 3.7 0 1 5.4 2.6 11.3 2.9 8 .3 9.8-1 10.6-1.8 1.1-1.3.8-2.5-.4-3.6z", fill "#cdf8f5" ]
    , [ d "M98.3 98c-.5-1.3-3-3.5-8.4-6.2-5-2.5-11-3.3-11.4-2.4-.5 1 3.3 5 8.3 8.2 6.9 4.3 9 4 10 3.7 1.7-.5 2-1.7 1.5-3.3z", fill "#c1d9ff" ]
    , [ d "M99.4 98.3c.3-1.4-.8-4.5-4.1-9.5-3-4.7-7.8-8.4-8.7-7.8-1 .6.4 6 3.1 11.2 3.8 7.2 5.7 8 6.8 8.3 1.7.4 2.6-.6 3-2.2z", fill "#80a0d9" ]
    , [ d "M100.2 99.2c1-1.1 1.6-4.4 1.2-10.4-.3-5.5-2.5-11.1-3.6-11-1.1 0-2.7 5.3-2.9 11.2-.3 8.1 1 9.8 1.8 10.6 1.3 1.2 2.5.8 3.5-.4z", fill "#c1d9ff" ]
    , [ d "M97.1 98.8c-.3-1.5.7-4.6 4-9.7 3-4.6 7.7-8.4 8.6-7.9 1 .6-.3 6-3 11.3-3.7 7.2-5.5 8-6.7 8.4-1.7.4-2.6-.6-2.9-2.1z", fill "#80a0d9" ]
    , [ d "M98.2 98.4c.5-1.3 3-3.6 8.3-6.3 5-2.6 10.9-3.5 11.4-2.5s-3.3 5-8.2 8.2c-6.8 4.4-8.9 4.2-10 4-1.7-.6-2-1.8-1.5-3.4z", fill "#86caea" ]
    , [ d "M99.4 98.7c1-1 4.3-1.6 10.3-1.3 5.6.2 11.2 2.4 11.1 3.5 0 1-5.3 2.7-11.2 3-8 .4-9.8-.8-10.6-1.6-1.2-1.3-.8-2.5.4-3.6z", fill "#c1d9ff" ]
    , [ d "M100 99.5c1.4-.3 4.6.8 9.6 4 4.7 3 8.5 7.7 8 8.6-.6 1-6-.3-11.4-3-7.2-3.6-8-5.5-8.3-6.7-.4-1.7.5-2.6 2-2.9z", fill "#86caea" ]
    , [ d "M100.5 100.5c1.4.4 3.6 2.9 6.4 8.2 2.5 5 3.4 10.9 2.5 11.4-1 .6-5-3.2-8.3-8.2-4.4-6.8-4.2-8.8-3.9-10 .5-1.6 1.8-2 3.3-1.4z", fill "#80a0d9" ]
    ]


largePetals : List (List (Svg.Attribute msg))
largePetals =
    [ [ d "M93 99.5c-4 1.4-10.6 8.8-18.5 24.5-7.4 14.6-10 32-7.3 33.6 2.9 1.5 14.7-9.7 24.2-24.4 12.8-20 12.2-26 11.2-29.4-1.5-5-5.2-5.8-9.6-4.3z", fill "#3b89dd" ]
    , [ d "M93.9 102.9C91 106 89 115.7 90 133.3c1 16.3 7.4 32.8 10.6 32.7 3.2 0 7.9-15.7 8.7-33.2 1-23.7-2.5-28.7-5-31-3.7-3.6-7.3-2.5-10.4 1z", fill "#0d2757" ]
    , [ d "M94 96.2c-4.3-.8-13.6 2.3-28.3 12-13.8 8.9-24.8 22.7-23.1 25.4 1.7 2.8 17.5-1 33-9 21.2-11 23.7-16.5 24.5-19.9 1.2-5-1.6-7.5-6.2-8.5z", fill "#bfdff0" ]
    , [ d "M96.4 93.8C93 91 83.5 89 65.9 90c-16.3 1-32.8 7.4-32.7 10.6 0 3.2 15.7 7.8 33.2 8.7 23.7 1 28.7-2.5 31-5 3.6-3.8 2.5-7.4-1-10.5z", fill "#6f9de7" ]
    , [ d "M99.7 93c-1.4-4-8.7-10.6-24.4-18.5-14.7-7.4-32.1-10-33.7-7.3C40.1 70.1 51.3 82 66 91.4c20 12.8 26.1 12.2 29.4 11.2 5-1.5 5.8-5.2 4.3-9.6z", fill "#3945a1" ]
    , [ d "M103 93.9c.8-4.2-2.3-13.5-11.9-28.3-9-13.7-22.8-24.7-25.5-23-2.8 1.7 1 17.5 9 33 11 21.1 16.5 23.7 19.9 24.5 5 1.2 7.6-1.6 8.5-6.2z", fill "#3b89dd" ]
    , [ d "M105.4 96.3c2.8-3.2 4.8-12.8 3.8-30.4-1-16.3-7.4-32.8-10.6-32.7-3.2 0-7.9 15.7-8.7 33.2-1 23.7 2.5 28.7 5 31 3.8 3.6 7.4 2.5 10.5-1z", fill "#0d2757" ]
    , [ d "M96.2 95c-.8-4.1 2.3-13.5 11.9-28.2 9-13.7 22.8-24.7 25.5-23 2.8 1.6-1 17.5-9 33-11 21.1-16.5 23.7-19.9 24.5-5 1.2-7.6-1.6-8.5-6.2z", fill "#3b89dd" ]
    , [ d "M99.5 94.2c1.4-4 8.7-10.6 24.4-18.6 14.7-7.3 32.1-10 33.7-7.2 1.5 2.8-9.7 14.7-24.4 24.2-20 12.8-26.1 12.2-29.4 11.2-5-1.5-5.8-5.2-4.3-9.6z", fill "#3945a1" ]
    , [ d "M102.8 95c3.3-2.8 12.9-4.8 30.5-3.8 16.3 1 32.8 7.3 32.7 10.6 0 3.2-15.7 7.8-33.2 8.6-23.7 1.1-28.7-2.4-31-5-3.6-3.7-2.5-7.3 1-10.4z", fill "#6f9de7" ]
    , [ d "M104.6 97.4c4.2-.9 13.6 2.2 28.3 11.8 13.7 9 24.7 22.8 23 25.6-1.6 2.7-17.5-1-33-9.1-21.1-11-23.7-16.5-24.5-19.8-1.2-5 1.6-7.6 6.2-8.5z", fill "#3b89dd" ]
    , [ d "M106.1 100.1c4.1 1.4 10.6 8.7 18.6 24.4 7.4 14.7 10 32.1 7.2 33.7-2.8 1.5-14.7-9.7-24.2-24.4-12.8-20-12.2-26.1-11.2-29.4 1.5-5 5.2-5.8 9.6-4.3z", fill "#3945a1" ]
    ]



-- Config


vbWidth : number
vbWidth =
    200


vbHeight : number
vbHeight =
    200
