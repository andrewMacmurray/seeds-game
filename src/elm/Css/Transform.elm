module Css.Transform exposing
    ( Transform
    , fromTransform
    , render
    , rotateX
    , rotateY
    , rotateZ
    , scale
    , translate
    , translateX
    , translateY
    , translateZ
    )

import Css.Unit exposing (..)


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


render : List Transform -> String
render =
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
            rotate_ "Z" n

        RotateX n ->
            rotate_ "X" n

        RotateY n ->
            rotate_ "Y" n

        Scale n ->
            scale_ n

        Translate { x, y } ->
            translate_ x y

        TranslateX n ->
            translateX_ n

        TranslateY n ->
            translateY_ n

        TranslateZ n ->
            translateZ_ n


scale_ : Float -> String
scale_ n =
    join [ "scale(", String.fromFloat n, ")" ]


translate_ : Float -> Float -> String
translate_ x y =
    join [ "translate(", px x, ",", px y, ")" ]


translateX_ : Float -> String
translateX_ n =
    join [ "translateX(", px n, ")" ]


translateY_ : Float -> String
translateY_ n =
    join [ "translateY(", px n, ")" ]


translateZ_ : Float -> String
translateZ_ n =
    join [ "translateZ(", px n, ")" ]


rotate_ : String -> Float -> String
rotate_ axis n =
    join [ "rotate", axis, "(", deg n, ")" ]


svgTranslate : Float -> Float -> String
svgTranslate x y =
    join
        [ "translate("
        , String.fromFloat x
        , " "
        , String.fromFloat y
        , ")"
        ]


join : List String -> String
join =
    String.join ""
