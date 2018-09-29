module Helpers.Css.Format exposing
    ( deg
    , gradientStop
    , linearGradient
    , ms
    , pc
    , px
    , rotateX
    , rotateY
    , rotateZ
    , scale
    , svgTranslate
    , translate
    , translateX
    , translateY
    , translateZ
    )

-- Transforms


scale : number -> String
scale n =
    join [ "scale(", toString n, ")" ]


translate : number -> number -> String
translate x y =
    join [ "translate(", px x, ",", px y, ")" ]


translateX : number -> String
translateX n =
    join [ "translateX(", px n, ")" ]


toString : number -> String
toString =
    Debug.toString


join : List String -> String
join =
    String.join ""


translateY : number -> String
translateY n =
    join [ "translateY(", px n, ")" ]


translateZ : number -> String
translateZ n =
    join [ "translateZ(", px n, ")" ]


rotateX : number -> String
rotateX =
    rotate "X"


rotateY : number -> String
rotateY =
    rotate "Y"


rotateZ : number -> String
rotateZ =
    rotate "Z"


rotate : String -> number -> String
rotate axis n =
    join [ "rotate", axis, "(", deg n, ")" ]


svgTranslate : number -> number -> String
svgTranslate x y =
    join [ "translate(", toString x, " ", toString y, ")" ]



-- Units


px : number -> String
px n =
    toString n ++ "px"


pc : number -> String
pc n =
    toString n ++ "%"


ms : number -> String
ms n =
    toString n ++ "ms"


deg : number -> String
deg n =
    toString n ++ "deg"



-- Misc


gradientStop : String -> number -> String
gradientStop color percent =
    join [ color, " ", pc percent ]


linearGradient : String -> String
linearGradient x =
    join [ "linear-gradient(", x, ")" ]
