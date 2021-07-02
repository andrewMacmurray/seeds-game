module Element.Transition exposing
    ( alpha
    , background
    , transform
    )

import Element exposing (htmlAttribute)
import Simple.Transition as Transition


background : Transition.Millis -> Element.Attribute msg
background duration =
    htmlAttribute
        (Transition.properties
            [ Transition.backgroundColor duration []
            ]
        )


alpha : Transition.Millis -> Element.Attribute msg
alpha duration =
    htmlAttribute
        (Transition.properties
            [ Transition.opacity duration []
            ]
        )


transform : Transition.Millis -> Element.Attribute msg
transform duration =
    htmlAttribute
        (Transition.properties
            [ Transition.transform duration [] ]
        )
