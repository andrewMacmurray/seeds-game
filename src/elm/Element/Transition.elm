module Element.Transition exposing (alpha)

import Element exposing (htmlAttribute)
import Simple.Transition as Transition


alpha : Transition.Millis -> List Transition.Option -> Element.Attribute msg
alpha duration options =
    properties
        [ Transition.opacity duration options
        ]


properties : List Transition.Property -> Element.Attribute msg
properties =
    htmlAttribute << Transition.properties
