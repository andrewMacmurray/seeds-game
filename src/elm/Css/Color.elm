module Css.Color exposing
    ( Color
    , black
    , lightGold
    , white
    )


type alias Color =
    String



-- Gradients


rgb : Int -> Int -> Int -> Color
rgb r g b =
    "rgb("
        ++ String.join ","
            [ String.fromInt r
            , String.fromInt g
            , String.fromInt b
            ]
        ++ ")"



-- Colors


lightGold : Color
lightGold =
    rgb 255 199 19


white : Color
white =
    rgb 255 255 255


black : Color
black =
    rgb 0 0 0
