module Element.Flower.Sunflower exposing
    ( animated
    , static
    )

import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Animated as Animated
import Utils.Svg exposing (..)



-- Static


static : Svg msg
static =
    Svg.svg [ viewBox_ 0 0 vw vh, width "100%" ]
        [ Svg.g [] petals_
        , Svg.path core_ []
        ]



-- Animated


animated : Animation.Millis -> Svg msg
animated delay =
    Svg.svg [ viewBox_ 0 0 vw vh, width "100%" ] (petals delay ++ [ core delay ])



-- Blooming Petals


bloomPetal : Int -> Animation.Millis -> Animation
bloomPetal index delay =
    Animation.steps
        { startAt = [ P.scale 0 ]
        , options =
            [ Animation.cubic 0.34 1.56 0.64 1
            , Animation.delay ((index * 75) + delay)
            ]
        }
        [ Animation.waitTillComplete (growCore delay)
        , Animation.step 1000 [ P.scale 1 ]
        ]


petals : Animation.Millis -> List (Svg msg)
petals delay =
    List.indexedMap
        (\i p -> Animated.g (bloomPetal i delay) [ style (transformOrigin_ (vw / 2) (vh / 2)) ] [ p ])
        petals_


petals_ : List (Svg msg)
petals_ =
    [ Svg.path [ d "M371.2 277.1s10.6 81 .6 118-57.6 97.9-57.6 97.9-29.7-58.5-24.1-98c5.5-39.7 25.6-97.8 37.7-108.7 12-10.9 43.4-9.2 43.4-9.2", fill "#e2e318" ] []
    , Svg.path [ d "M316.8 291.2S239.7 264 211 238.4c-28.6-25.7-61.4-95.5-61.4-95.5s65.7 0 98.5 22.8c32.9 22.8 75.7 67 80 82.7 4.3 15.7-11.4 42.8-11.4 42.8", fill "#e2e318" ] []
    , Svg.path [ d "M319.5 332.8s-81.7-3.2-116.5-19.3c-34.9-16.1-87-73.2-87-73.2s62.8-19.4 101-7.2c38 12.1 92 41.7 100.8 55.5 8.7 13.7 1.7 44.2 1.7 44.2", fill "#fff100" ] []
    , Svg.path [ d "M330.6 335.3s-73.2 36.3-111.6 38.8c-38.3 2.6-111.3-22.6-111.3-22.6s45.8-47 85-54.6c39.3-7.6 101-7.5 115.2.4 14.2 7.9 22.7 38 22.7 38", fill "#fff100" ] []
    , Svg.path [ d "M355.8 337.2s-58.9 56.6-94.7 70.6c-35.7 14-113 12-113 12s29.5-58.7 64.6-77.8c35.2-19 94-37.4 110-34.2 15.9 3.2 33 29.4 33 29.4", fill "#ffcc47" ] []
    , Svg.path [ d "M391.5 311.8s-36.9 72.9-66 97.8c-29.2 25-102.8 48.5-102.8 48.5s8.5-65 35.3-94.6c27-29.6 76.3-66.3 92.5-68.5 16.1-2.2 41 16.8 41 16.8", fill "#fff100" ] []
    , Svg.path [ d "M324.3 286.6s-54-61.2-66.4-97.6C245.5 152.7 251 75.7 251 75.7s57.3 32 74.8 68c17.6 35.9 33.3 95.3 29.4 111.1-4 15.8-30.9 31.8-30.9 31.8", fill "#fff100" ] []
    , Svg.path [ d "M303.6 286.2s-4.6-81.5 8.2-117.7c12.8-36.1 64.8-93.3 64.8-93.3s25.2 60.6 16.7 99.7c-8.5 39-33 95.5-45.8 105.4-12.8 10-44 6-44 6", fill "#ffcc47" ] []
    , Svg.path [ d "M302.8 287s33-74.7 60.8-101.2c27.8-26.4 100-53.8 100-53.8s-5 65.4-30.3 96.4-72.7 70.2-88.7 73.3c-16 3-41.8-14.7-41.8-14.7", fill "#fff100" ] []
    , Svg.path [ d "M342.7 304.6s44.1-68.7 75.7-90.6c31.6-21.8 107.2-37.7 107.2-37.7s-15.1 63.8-44.9 90.5c-29.8 26.7-82.7 58.2-99 58.7-16.2.6-39-20.9-39-20.9", fill "#e2e318" ] []
    , Svg.path [ d "M341.3 279s80.1-16 117.8-8.6S561 321 561 321s-56.5 33.6-96.4 30.8c-39.9-2.8-99.3-18.9-111-30.1-11.8-11.3-12.2-42.6-12.2-42.6", fill "#fff100" ] []
    , Svg.path [ d "M321.9 291.2s79.7 18 111 40.3c31.3 22.2 72 87.8 72 87.8s-65.3 7.5-100.5-11.3c-35.2-19-82.9-58-89-73-6-15.1 6.5-43.8 6.5-43.8", fill "#e2e318" ] []
    , Svg.path [ d "M292.4 278.4s72.5 37.7 97.1 67.2c24.6 29.5 47.2 103.3 47.2 103.3s-65-9.3-94.3-36.6c-29.2-27.2-65.3-77-67.4-93.2-2-16.1 17.4-40.7 17.4-40.7", fill "#fff100" ] []
    ]



-- Core


growCore : Animation.Millis -> Animation
growCore delay =
    Animation.fromTo
        { duration = 1000
        , options = [ Animation.easeOutBack, Animation.delay delay ]
        }
        [ P.scale 0 ]
        [ P.scale 1 ]


core : Animation.Millis -> Svg msg
core delay =
    Animated.path (growCore delay) core_ []


core_ : List (Svg.Attribute msg)
core_ =
    [ d "M393.4 296c0 33.7-30.3 61-67.6 61s-67.5-27.3-67.5-61 30.2-61 67.5-61 67.6 27.3 67.6 61"
    , fill "#8a5d3b"
    , style (transformOrigin_ (vw / 2 - 10) (vh / 2 + 10))
    ]



-- Config


vw : number
vw =
    669


vh : number
vh =
    569
