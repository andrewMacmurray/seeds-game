module Utils.Animation exposing (..)

import Formatting exposing (..)
import Utils.Style exposing (scale_, translateY_)


fall =
    List.range 1 8
        |> List.map (\magnitude -> List.map (\( step, y ) -> print translateYStep step y) (fallsteps magnitude))
        |> List.map (String.join " ")
        |> List.indexedMap (\i steps -> print animation ("fall-" ++ (toString i)) steps)
        |> String.join " "


fallsteps x =
    let
        floatX =
            ((toFloat x) * 51) / 100
    in
        [ ( 0, 0 )
        , ( 75, floatX * 105 )
        , ( 100, floatX * 100 )
        ]


bulge =
    [ ( 0, 0.5 )
    , ( 50, 1.3 )
    , ( 100, 1 )
    ]
        |> List.map (\( step, scale ) -> bulgeStep step scale)
        |> String.join " "
        |> print animation "bulge"


bounces =
    [ ( 0, -1000 )
    , ( 60, 25 )
    , ( 75, -10 )
    , ( 90, 5 )
    , ( 100, 0 )
    ]
        |> List.map (\( step, y ) -> print translateYStep step y)
        |> String.join " "
        |> print animation "bounce"


bulgeStep =
    print scaleStep


bounceStep =
    print translateYStep


animation =
    s "@keyframes " <> string <> s " { " <> string <> s " }"


scaleStep =
    int <> s "% { transform: " <> scale_ <> s "; }"


translateYStep =
    int <> s "% { transform: " <> translateY_ <> s "; }"
