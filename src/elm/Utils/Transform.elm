module Utils.Transform exposing
    ( Transform
    , rotate
    , scale
    , toString
    , translate
    , translateY
    )

import Utils.Unit as Unit



-- Transform


type Transform
    = Translate XY
    | TranslateY Float
    | Scale Float
    | Rotate Float


type alias XY =
    { x : Float
    , y : Float
    }



-- Construct


scale : Float -> Transform
scale =
    Scale


translate : Float -> Float -> Transform
translate x y =
    Translate (XY x y)


translateY : Float -> Transform
translateY =
    TranslateY


rotate : Float -> Transform
rotate =
    Rotate



-- To String


toString : List Transform -> String
toString =
    List.map fromTransform >> String.join " "


fromTransform : Transform -> String
fromTransform ts =
    case ts of
        Rotate n ->
            rotate_ n

        Scale n ->
            scale_ n

        Translate { x, y } ->
            translate_ x y

        TranslateY n ->
            translateY_ n


scale_ : Float -> String
scale_ n =
    join [ "scale(", String.fromFloat n, ")" ]


translate_ : Float -> Float -> String
translate_ x y =
    join [ "translate(", px x, ",", px y, ")" ]


translateY_ : Float -> String
translateY_ n =
    join [ "translateY(", px n, ")" ]


rotate_ : Float -> String
rotate_ n =
    join [ "rotateZ(", Unit.deg n, ")" ]


px : Float -> String
px =
    Unit.px << round


join : List String -> String
join =
    String.concat
