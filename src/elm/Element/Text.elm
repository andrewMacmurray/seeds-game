module Element.Text exposing
    ( color
    , fonts
    , large
    , medium
    , small
    , spaced
    , text
    , wideSpaced
    )

import Element exposing (Attribute, Element)
import Element.Font as Font
import Element.Palette as Palette



-- Text


text : List (Attribute msg) -> String -> Element msg
text attrs t =
    Element.el (medium :: darkYellow :: attrs) (Element.text t)



-- Spacing


wideSpaced : Attribute msg
wideSpaced =
    Font.letterSpacing 5


spaced : Attribute msg
spaced =
    Font.letterSpacing 2



-- Size


large : Element.Attr decorative msg
large =
    Font.size 20


medium : Element.Attr decorative msg
medium =
    Font.size 16


small : Element.Attr decorative msg
small =
    Font.size 12



-- Color


darkYellow : Element.Attr decorative msg
darkYellow =
    Font.color Palette.darkYellow


color : Element.Color -> Element.Attr decorative msg
color =
    Font.color



-- Font


fonts : Attribute msg
fonts =
    Font.family
        [ Font.typeface "AbeeZee"
        , Font.typeface "Helvetica Neue"
        , Font.typeface "Helvetica"
        , Font.typeface "Arial"
        ]
