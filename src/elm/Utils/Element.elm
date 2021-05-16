module Utils.Element exposing (disableTouch, style)

import Element exposing (Attribute)
import Html.Attributes


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


style : String -> String -> Attribute msg
style a b =
    Element.htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    Element.htmlAttribute << Html.Attributes.class
