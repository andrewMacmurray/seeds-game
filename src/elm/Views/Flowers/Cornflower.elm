module Views.Flowers.Cornflower exposing (animated, static)

import Css.Animation as Animation
import Css.Style as Style
import Css.Transform as Transform
import Helpers.Svg exposing (..)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


static : Svg msg
static =
    Svg.svg [ viewBox_ 0 0 vbWidth vbHeight ]
        [ Svg.g [] largePetals
        , Svg.g [] smallPetals
        ]


animated : Int -> Svg msg
animated delay =
    Svg.svg [ viewBox_ 0 0 vbWidth vbHeight ]
        [ Svg.g [] <| animatePetals delay largePetals
        , Svg.g [] <| animatePetals (delay + 750) smallPetals
        ]


animatePetals : Int -> List (Svg msg) -> List (Svg msg)
animatePetals delay =
    List.indexedMap <| animatePetal delay


animatePetal : Int -> Int -> Svg msg -> Svg msg
animatePetal delay i petal =
    Svg.g
        [ Style.svgStyles
            [ Animation.animation "bulge-elastic-big"
                1000
                [ Animation.delay <| i * 30 + delay
                , Animation.linear
                ]
            , Style.transform [ Transform.scale 0 ]
            , Style.transformOriginPx (vbWidth / 2) (vbHeight / 2)
            ]
        ]
        [ petal ]


smallPetals : List (Svg msg)
smallPetals =
    [ Svg.path [ d "M343 357c-5 1-12 9-21 27-8 17-11 36-8 38s17-11 27-28c14-22 14-29 12-33-1-5-5-6-10-4z", fill "#d4f5f9" ] []
    , Svg.path [ d "M344 360c-4 4-6 15-5 34 2 19 9 37 13 37 3 0 8-18 9-37 1-27-3-32-6-35-4-4-8-3-11 1z", fill "#c1d9ff" ] []
    , Svg.path [ d "M344 353c-5-1-16 3-32 13-15 11-28 26-26 29s20-1 37-10c24-13 27-19 28-23 1-5-2-8-7-9z", fill "#86caea" ] []
    , Svg.path [ d "M346 350c-3-3-14-5-34-4-18 1-37 9-37 12 1 4 18 9 38 10 26 1 32-3 35-6 4-4 2-8-2-12z", fill "#cdf8f5" ] []
    , Svg.path [ d "M350 349c-2-4-10-12-28-20-16-9-36-11-37-8-2 3 11 16 27 27 23 14 30 13 33 12 6-2 7-6 5-11z", fill "#c1d9ff" ] []
    , Svg.path [ d "M354 350c1-5-3-15-14-31-10-16-26-28-29-26s2 20 11 37c12 24 18 26 22 27 6 1 9-2 10-7z", fill "#80a0d9" ] []
    , Svg.path [ d "M356 353c4-4 6-15 4-34-1-19-8-37-12-37-3 0-8 18-9 37-1 27 3 33 6 35 4 4 8 3 11-1z", fill "#c1d9ff" ] []
    , Svg.path [ d "M346 352c-1-5 3-16 13-32s26-28 29-26-1 19-10 37c-12 24-19 27-22 27-6 2-9-1-10-6z", fill "#80a0d9" ] []
    , Svg.path [ d "M350 351c1-5 9-12 27-21 16-9 36-12 38-9 1 3-11 17-27 27-23 15-30 14-33 13-6-1-7-5-5-10z", fill "#86caea" ] []
    , Svg.path [ d "M354 351c3-3 14-5 34-4 18 1 36 8 36 11 0 4-17 9-37 11-26 1-32-3-35-6-4-4-2-8 2-12z", fill "#c1d9ff" ] []
    , Svg.path [ d "M356 354c4-1 15 2 31 13 16 10 28 26 26 29-1 3-19-1-37-10-24-12-26-19-27-22-2-6 1-9 7-10z", fill "#86caea" ] []
    , Svg.path [ d "M357 357c5 2 12 10 21 27s12 36 9 38c-4 2-17-11-28-27-14-22-14-29-12-33 1-6 5-6 10-5z", fill "#80a0d9" ] []
    ]


largePetals : List (Svg msg)
largePetals =
    [ Svg.path [ d "M333 354c-14 5-35 29-62 81-24 48-33 106-23 111 9 5 48-32 79-81 42-66 41-86 37-97-5-16-17-19-31-14z", fill "#3b89dd" ] []
    , Svg.path [ d "M335 365c-9 11-16 42-12 100 3 54 24 109 35 108 10 0 26-51 28-109 4-78-8-95-16-103-12-11-24-8-35 4z", fill "#0d2757" ] []
    , Svg.path [ d "M336 343c-14-3-45 8-94 39-45 30-81 76-76 85 6 9 58-4 109-30 70-36 78-55 81-66 4-16-5-25-20-28z", fill "#bfdff0" ] []
    , Svg.path [ d "M344 335c-11-9-43-16-101-12-54 3-108 24-108 35 1 10 52 26 110 28 78 4 95-8 102-16 12-13 8-24-3-35z", fill "#6f9de7" ] []
    , Svg.path [ d "M355 332c-5-13-29-35-81-61-48-24-106-33-111-23-5 9 32 48 81 79 66 42 86 40 97 37 16-5 19-17 14-32z", fill "#3945a1" ] []
    , Svg.path [ d "M366 335c2-13-8-44-40-93-29-45-75-81-84-76-9 6 4 58 30 109 36 70 54 78 65 81 17 4 25-5 29-21z", fill "#3b89dd" ] []
    , Svg.path [ d "M373 344c10-11 16-43 13-101-3-54-24-108-35-108-11 1-26 52-29 110-3 78 9 94 17 102 12 12 24 8 34-3z", fill "#0d2757" ] []
    , Svg.path [ d "M343 339c-3-13 8-44 39-93 30-45 76-81 85-76 9 6-4 58-30 109-36 70-55 78-66 81-16 4-25-5-28-21z", fill "#3b89dd" ] []
    , Svg.path [ d "M354 336c5-13 29-35 81-61 48-24 106-33 111-24 5 10-32 49-81 80-66 42-86 40-97 37-16-5-19-17-14-32z", fill "#3945a1" ] []
    , Svg.path [ d "M365 339c11-9 42-16 100-12 54 3 109 24 108 34 0 11-52 26-109 29-78 4-95-8-103-16-11-13-8-25 4-35z", fill "#6f9de7" ] []
    , Svg.path [ d "M371 347c14-3 45 7 93 39 45 30 82 75 76 84-5 9-58-3-109-30-70-36-78-54-81-65-3-17 6-25 21-28z", fill "#3b89dd" ] []
    , Svg.path [ d "M376 356c13 5 35 29 61 81 24 48 33 106 24 111s-49-32-80-81c-42-66-40-86-37-97 5-16 17-19 32-14z", fill "#3945a1" ] []
    ]


vbWidth =
    709


vbHeight =
    709
