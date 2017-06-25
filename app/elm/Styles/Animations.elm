module Styles.Animations exposing (..)

import Formatting exposing ((<>), print)
import Styles.Utils exposing (keyframesAnimation, opacity_, scale_, step_, transform_, translateY_)


animationsToAdd : List String
animationsToAdd =
    [ fallDistances
    , bulge
    , bounce
    , bulgeFade
    ]


bulgeFade : String
bulgeFade =
    [ ( 0, 1, 1 )
    , ( 100, 2.5, 0 )
    ]
        |> List.map (\( step, scale, opacity ) -> stepScaleFade step scale opacity)
        |> keyframesAnimation "bulge-fade"


fallDistances : String
fallDistances =
    List.range 1 8
        |> List.map (\magnitude -> List.map (uncurry stepTranslateY) (fallsteps magnitude))
        |> List.indexedMap makeFallAnimation
        |> String.join " "


makeFallAnimation : Int -> List String -> String
makeFallAnimation i =
    keyframesAnimation ("fall-" ++ toString i)


fallsteps : Int -> List ( number, Float )
fallsteps x =
    let
        floatX =
            ((toFloat x) * 51) / 100
    in
        [ ( 0, 0 )
        , ( 75, floatX * 105 )
        , ( 100, floatX * 100 )
        ]


bulge : String
bulge =
    [ ( 0, 0.5 )
    , ( 50, 1.3 )
    , ( 100, 1 )
    ]
        |> List.map (uncurry stepScale)
        |> keyframesAnimation "bulge"


bounce : String
bounce =
    [ ( 0, -300 )
    , ( 60, 25 )
    , ( 75, -10 )
    , ( 90, 5 )
    , ( 100, 0 )
    ]
        |> List.map (uncurry stepTranslateY)
        |> keyframesAnimation "bounce"


stepScaleFade : Int -> number -> number -> String
stepScaleFade =
    ((transform_ scale_) <> opacity_)
        |> step_
        |> print


stepScale : Int -> number -> String
stepScale =
    transform_ scale_
        |> step_
        |> print


stepTranslateY : Int -> number -> String
stepTranslateY =
    transform_ translateY_
        |> step_
        |> print
