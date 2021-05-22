module Utils.Element exposing
    ( disableTouch
    , maybe
    , style
    )

import Element exposing (Attribute, Element)
import Html.Attributes


maybe : (a -> Element msg) -> Maybe a -> Element msg
maybe toElement =
    Maybe.map toElement >> Maybe.withDefault Element.none


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


style : String -> String -> Attribute msg
style a b =
    Element.htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    Element.htmlAttribute << Html.Attributes.class
