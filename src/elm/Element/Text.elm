module Element.Text exposing
    ( bold
    , color
    , f3
    , f4
    , f5
    , f6
    , fonts
    , spaced
    , text
    , white
    , wideSpaced
    )

import Element exposing (Attribute, Element)
import Element.Font as Font
import Element.Palette as Palette



-- Text


text : List (Attribute msg) -> String -> Element msg
text attrs t =
    Element.el (f5 :: darkYellow :: attrs) (Element.text t)


bold : Attribute msg
bold =
    Font.bold



-- Spacing


wideSpaced : Attribute msg
wideSpaced =
    Font.letterSpacing 5


spaced : Attribute msg
spaced =
    Font.letterSpacing 2



-- Size


f3 : Element.Attr decorative msg
f3 =
    Font.size 22


f4 : Element.Attr decorative msg
f4 =
    Font.size 18


f5 : Element.Attr decorative msg
f5 =
    Font.size 16


f6 : Element.Attr decorative msg
f6 =
    Font.size 12



-- Color


darkYellow : Element.Attr decorative msg
darkYellow =
    Font.color Palette.darkYellow


color : Element.Color -> Element.Attr decorative msg
color =
    Font.color


white : Element.Attr decorative msg
white =
    color Palette.white



-- Font


fonts : Attribute msg
fonts =
    Font.family
        [ Font.typeface "AbeeZee"
        , Font.typeface "Helvetica Neue"
        , Font.typeface "Helvetica"
        , Font.typeface "Arial"
        ]
