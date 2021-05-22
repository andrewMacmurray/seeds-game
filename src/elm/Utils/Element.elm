module Utils.Element exposing
    ( disableTouch
    , id
    , maybe
    , style
    )

import Element exposing (Attribute, Element)
import Html.Attributes


maybe : (a -> Element msg) -> Maybe a -> Element msg
maybe toElement =
    Maybe.map toElement >> Maybe.withDefault Element.none


id : String -> Attribute msg
id =
    Element.htmlAttribute << Html.Attributes.id


disableTouch : Attribute msg
disableTouch =
    class "touch-disabled"


style : String -> String -> Attribute msg
style a b =
    Element.htmlAttribute (Html.Attributes.style a b)


class : String -> Attribute msg
class =
    Element.htmlAttribute << Html.Attributes.class
