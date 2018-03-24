module Helpers.Css.Transform
    exposing
        ( Transform
        , transformStyle
        , transformSvg
        , transform
        , scale
        , translate
        , translateX
        , translateY
        , rotateX
        , rotateY
        , rotateZ
        , fromTransform
        )

import Formatting exposing (print)
import Helpers.Css.Format exposing (rotate_, translate_, translateY_, translateX_, scale_)
import Helpers.Css.Style exposing (Style)


type Transform
    = Translate XY
    | TranslateX Float
    | TranslateY Float
    | Scale Float
    | RotateX Float
    | RotateY Float
    | RotateZ Float


type alias XY =
    { x : Float
    , y : Float
    }



{-
   myTransform =
       transformStyle
           [ translate 10 10
           , scale 2
           , rotateZ 10
           ]

    -- ("transform", "translate(10px, 10px) scale(2) rotateZ(10deg)")
-}


transformSvg : List Transform -> String
transformSvg =
    transform >> (++) "transform: "


transformStyle : List Transform -> Style
transformStyle =
    transform >> (,) "transform"


transform : List Transform -> String
transform =
    List.map fromTransform >> String.join " "


scale : Float -> Transform
scale =
    Scale


translate : Float -> Float -> Transform
translate x y =
    Translate <| XY x y


translateX : Float -> Transform
translateX =
    TranslateX


translateY : Float -> Transform
translateY =
    TranslateY


rotateX : Float -> Transform
rotateX =
    RotateX


rotateY : Float -> Transform
rotateY =
    RotateY


rotateZ : Float -> Transform
rotateZ =
    RotateZ


fromTransform : Transform -> String
fromTransform ts =
    case ts of
        RotateZ n ->
            (print <| rotate_ "Z") n

        RotateX n ->
            (print <| rotate_ "X") n

        RotateY n ->
            (print <| rotate_ "Y") n

        Scale n ->
            print scale_ n

        Translate { x, y } ->
            print translate_ x y

        TranslateX n ->
            print translateX_ n

        TranslateY n ->
            print translateY_ n
