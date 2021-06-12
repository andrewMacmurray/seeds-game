module Css.Transform exposing
    ( Transform
    , render
    , rotate
    , scale
    , translate
    , translateX
    , translateY
    )

import Css.Unit exposing (..)


type Transform
    = Translate XY
    | TranslateX Float
    | TranslateY Float
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


rotate : Float -> Transform
rotate =
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


rotate_ : String -> Float -> String
rotate_ axis n =
    join [ "rotate", axis, "(", deg n, ")" ]


join : List String -> String
join =
    String.concat
