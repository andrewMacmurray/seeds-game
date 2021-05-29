module Utils.Element exposing
    ( applyIf
    , class
    , disableTouch
    , empty
    , id
    , maybe
    , style
    , verticalGap
    )

import Element exposing (Attribute, Element)
import Html.Attributes


maybe : (a -> Element msg) -> Maybe a -> Element msg
maybe toElement =
    Maybe.map toElement >> Maybe.withDefault Element.none


id : String -> Attribute msg
id =
    Element.htmlAttribute << Html.Attributes.id


verticalGap : Int -> Element msg
verticalGap size =
    Element.el [ Element.height (Element.fillPortion size) ] Element.none


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


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
    Element.htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    Element.htmlAttribute << Html.Attributes.class
