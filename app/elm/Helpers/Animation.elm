module Helpers.Animation exposing (..)

import Formatting exposing (..)


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
    int <> s "% { transform: " <> scale <> s "; }"


translateYStep =
    int <> s "% { transform: " <> translateY <> s "; }"


px =
    float <> s "px"


translateY =
    s "translateY(" <> px <> s ")"


translate =
    s "translate(" <> px <> s ", " <> px <> s ")"


scale =
    s "scale(" <> float <> s ")"
