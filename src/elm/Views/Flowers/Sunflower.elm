module Views.Flowers.Sunflower exposing (sunflower)

import Helpers.Css.Animation exposing (FillMode(..), animationWithOptionsStyle, animationWithOptionsSvg)
import Helpers.Css.Style as Style exposing (opacityStyle, svgStyles, transformOrigin)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform as Transform
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


sunflower : Float -> Svg msg
sunflower delay =
    Svg.svg [ viewBox "-30 -25 237 220", width "100%" ]
        [ Svg.g [] <| List.indexedMap (fadePetal delay) petals
        , Svg.path
            [ d "M117 91c0 13-12 25-27 25-16 0-28-12-28-25 0-14 12-25 28-25 15 0 27 11 27 25"
            , fill "#8A5D3B"
            , svgStyles
                [ animationWithOptionsStyle
                    { name = "bulge-elastic-big"
                    , duration = 1000
                    , timing = Linear
                    , delay = Just delay
                    , fill = Forwards
                    , iteration = Nothing
                    }
                , transformOrigin "40% 45%"
                , opacityStyle 0
                ]
            ]
            []
        ]


fadePetal : Float -> Int -> Svg msg -> Svg msg
fadePetal delay index petal =
    let
        d =
            delay + 1100 + toFloat index * 60
    in
    Svg.g
        [ svgStyles
            [ Style.transform [ Transform.scale 0 ]
            , transformOrigin "center"
            , opacityStyle 0
            , animationWithOptionsStyle
                { name = "bulge-small"
                , duration = 900
                , timing = Ease
                , delay = Just d
                , iteration = Nothing
                , fill = Forwards
                }
            ]
        ]
        [ petal ]


petals : List (Svg msg)
petals =
    [ Svg.path [ d "M108 83s5 33 0 48c-4 15-23 40-23 40s-12-24-10-40 10-40 15-44c5-5 18-4 18-4m-22 6S54 77 42 67C31 56 17 28 17 28s27 0 41 9c13 9 31 28 33 34 1 6-5 18-5 18", fill "#E2E318" ]
        []
    , Svg.path [ d "M87 106s-34-2-48-8C25 91 3 68 3 68s26-8 42-3 38 17 41 23c4 5 1 18 1 18", fill "#FFF100" ]
        []
    , Svg.path [ d "M91 107s-30 15-45 16c-16 1-46-10-46-10s19-19 35-22 41-3 47 0 9 16 9 16", fill "#FFF100" ]
        []
    , Svg.path [ d "M76 83s30 16 40 28 19 42 19 42-27-3-39-15c-12-11-26-31-27-38s7-17 7-17", fill "#FFF100" ]
        []
    , Svg.path [ d "M102 108s-24 23-39 28c-15 6-46 5-46 5s12-24 26-32c15-7 39-15 45-14 7 2 14 13 14 13", fill "#FFCC47" ]
        []
    , Svg.path [ d "M116 97s-15 30-27 40-42 20-42 20 4-27 15-39 31-27 38-28c6-1 16 7 16 7M89 87S67 62 62 47 59 0 59 0s23 13 31 28c7 15 13 39 12 46-2 6-13 13-13 13", fill "#FFF100" ]
        []
    , Svg.path [ d "M80 87s-1-34 4-49 26-38 26-38 11 25 7 41c-3 16-13 39-19 43-5 4-18 3-18 3", fill "#FFCC47" ]
        []
    , Svg.path [ d "M80 87s14-31 25-42c11-10 41-22 41-22s-2 27-12 40c-11 13-30 29-37 30-6 1-17-6-17-6", fill "#FFF100" ]
        []
    , Svg.path [ d "M96 94s19-28 32-37c12-9 44-16 44-16s-7 27-19 38-34 23-41 24c-6 0-16-9-16-9", fill "#E2E318" ]
        []
    , Svg.path [ transform "translate(96 79)", d "M0 4s33-6 48-3c16 3 42 21 42 21S67 35 51 34c-17-1-41-7-46-12S0 4 0 4", fill "#FFF100" ] []
    , Svg.path [ d "M88 89s33 7 45 16c13 9 30 36 30 36s-27 3-41-4c-15-8-34-24-37-30-2-7 3-18 3-18", fill "#FFCC47" ]
        []
    ]
