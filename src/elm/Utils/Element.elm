module Utils.Element exposing
    ( disableTouch
    , style
    , visibleIf
    )

import Element exposing (Attribute, alpha)
import Html.Attributes


visibleIf : Bool -> Attribute msg
visibleIf condition =
    if condition then
        alpha 1

    else
        alpha 0


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


style : String -> String -> Attribute msg
style a b =
    Element.htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    Element.htmlAttribute << Html.Attributes.class
