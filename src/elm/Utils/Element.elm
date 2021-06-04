module Utils.Element exposing
    ( applyIf
    , bfv
    , class
    , disableTouch
    , empty
    , id
    , maybe
    , noZoom
    , onClickIf
    , originBottom
    , showIfJust
    , square
    , style
    , tf3d
    , tfs
    , verticalGap
    , visibleIf
    )

import Element exposing (..)
import Element.Events exposing (onClick)
import Html.Attributes


maybe : (a -> Element msg) -> Maybe a -> Element msg
maybe toElement =
    Maybe.map toElement >> Maybe.withDefault none


id : String -> Attribute msg
id =
    htmlAttribute << Html.Attributes.id


verticalGap : Int -> Element msg
verticalGap size =
    el [ height (fillPortion size) ] none


square : Int -> List (Attribute msg) -> Element msg -> Element msg
square n =
    sized n n


sized : Int -> Int -> List (Attribute msg) -> Element msg -> Element msg
sized w h attrs =
    el (List.append [ width (px w), height (px h) ] attrs)


visibleIf : Bool -> Attribute msg
visibleIf condition =
    if condition then
        alpha 1

    else
        alpha 0


showIfJust : (a -> Element msg) -> Maybe a -> Element msg
showIfJust toElement =
    Maybe.map toElement >> Maybe.withDefault none


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


noZoom : Attribute msg
noZoom =
    style "touch-action" "none"


originBottom : Attribute msg
originBottom =
    style "transform-origin" "bottom"


tf3d : Attribute msg
tf3d =
    style "-webkit-transform" "translate3d(0, 0, 0)"


bfv : Attribute msg
bfv =
    style "-webkit-backface-visibility" "hidden"


tfs : Attribute msg
tfs =
    style "-webkit-transform-style" "preserve-3d"


onClickIf : Bool -> msg -> Attribute msg
onClickIf condition msg =
    applyIf condition (onClick msg)


applyIf : Bool -> Attribute msg -> Attribute msg
applyIf condition attr =
    if condition then
        attr

    else
        empty


empty : Attribute msg
empty =
    class ""


style : String -> String -> Attribute msg
style a b =
    htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    htmlAttribute << Html.Attributes.class
