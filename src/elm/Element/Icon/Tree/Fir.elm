module Element.Icon.Tree.Fir exposing
    ( alive
    , dead
    )

import Element exposing (Color)
import Element.Palette as Palette
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg exposing (..)



-- Alive


alive : Svg msg
alive =
    fir_
        { left = leftColor
        , right = rightColor
        , leftPath = Svg.path
        , rightPath = Svg.path
        }



-- Dead


dead : Svg msg
dead =
    fir_
        { left = deadLeft
        , right = deadRight
        , leftPath = Svg.path
        , rightPath = Svg.path
        }



-- Internal


type alias Options msg =
    { left : Color
    , right : Color
    , leftPath : List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
    , rightPath : List (Svg.Attribute msg) -> List (Svg msg) -> Svg msg
    }


fir_ : Options msg -> Svg msg
fir_ { left, leftPath, right, rightPath } =
    Svg.svg
        [ viewBox_ 0 0 40 100
        , Svg.width_ 40
        , Svg.height_ 100
        ]
        [ Svg.path [ fill_ trunkColor, d "M12.2 41h6.6V75h-6.6z" ] []
        , leftPath
            [ d "M15.6.3s14.8 20.4 14.8 32.9c0 8.2-6.6 14.8-14.8 14.8V.4z"
            , fill_ left
            ]
            []
        , rightPath
            [ d "M.8 33.2C.8 21 14.7 1.6 15.5.4V48C7.4 48 .8 41.4.8 33.2z"
            , fill_ right
            ]
            []
        ]


trunkColor : Color
trunkColor =
    Palette.brown3


leftColor : Color
leftColor =
    Palette.green8


rightColor : Color
rightColor =
    Palette.green10


deadLeft : Color
deadLeft =
    Palette.brown8


deadRight : Color
deadRight =
    Palette.brown9