module Css.Transform exposing
    ( Transform
    , render
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


rotateZ : Float -> Transform
rotateZ =
    RotateZ


fromTransform : Transform -> String
fromTransform ts =
    case ts of
        RotateZ n ->
            rotate_ "Z" n

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


join : List String -> String
join =
    String.concat
