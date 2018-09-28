module Helpers.Css.Transform exposing
    ( Transform
    , fromTransform
    , rotateX
    , rotateY
    , rotateZ
    , scale
    , transform
    , transformStyle
    , transformSvg
    , translate
    , translateX
    , translateY
    , translateZ
    )

import Helpers.Css.Format as Format
import Helpers.Css.Style exposing (Style)


type Transform
    = Translate XY
    | TranslateX Float
    | TranslateY Float
    | TranslateZ Float
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
    transform >> (\b -> ( "transform", b ))


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


translateZ : Float -> Transform
translateZ =
    TranslateZ


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
            Format.rotateZ n

        RotateX n ->
            Format.rotateX n

        RotateY n ->
            Format.rotateY n

        Scale n ->
            Format.scale n

        Translate { x, y } ->
            Format.translate x y

        TranslateX n ->
            Format.translateX n

        TranslateY n ->
            Format.translateY n

        TranslateZ n ->
            Format.translateZ n
