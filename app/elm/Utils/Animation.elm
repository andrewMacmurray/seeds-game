module Utils.Animation exposing (..)

import Formatting exposing (..)
import Utils.Style exposing (scale_, transform_, translateY_)


fall : String
fall =
    List.range 1 8
        |> List.map (\magnitude -> List.map (\( step, y ) -> stepTranslateY step y) (fallsteps magnitude))
        |> List.map (String.join " ")
        |> List.indexedMap (\i steps -> animation ("fall-" ++ (toString i)) steps)
        |> String.join " "


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
        |> List.map (\( step, scale ) -> stepScale step scale)
        |> String.join " "
        |> animation "bulge"


bounces : String
bounces =
    [ ( 0, -1000 )
    , ( 60, 25 )
    , ( 75, -10 )
    , ( 90, 5 )
    , ( 100, 0 )
    ]
        |> List.map (\( step, y ) -> stepTranslateY step y)
        |> String.join " "
        |> animation "bounce"


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


animation : String -> String -> String
animation =
    print animation_


animation_ : Format r (String -> String -> r)
animation_ =
    s "@keyframes " <> string <> s " { " <> string <> s " }"


step_ : Format r a -> Format r (Int -> a)
step_ formatter =
    int <> s "% { " <> formatter <> s "; }"
