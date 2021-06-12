module Utils.Element exposing
    ( applyIf
    , class
    , disableTouch
    , empty
    , id
    , maybe
    , onClickIf
    , originBottom
    , preventScroll
    , square
    , style
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


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


preventScroll : Attribute msg
preventScroll =
    style "touch-action" "none"


originBottom : Attribute msg
originBottom =
    style "transform-origin" "bottom"


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
