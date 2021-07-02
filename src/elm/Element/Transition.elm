module Element.Transition exposing
    ( alpha
    , background
    , fill_
    , opacity_
    , transform
    , transform_
    )

import Element exposing (htmlAttribute)
import Html
import Simple.Transition as Transition



-- Elm UI


background : Transition.Millis -> Element.Attribute msg
background duration =
    htmlAttribute
        (Transition.properties
            [ Transition.backgroundColor duration []
            ]
        )


alpha : Transition.Millis -> Element.Attribute msg
alpha duration =
    htmlAttribute (opacity_ duration [])


transform : Transition.Millis -> Element.Attribute msg
transform duration =
    htmlAttribute (transform_ duration [])



-- Html


transform_ : Transition.Millis -> List Transition.Option -> Html.Attribute msg
transform_ duration options =
    Transition.properties
        [ Transition.transform duration options
        ]


opacity_ : Transition.Millis -> List Transition.Option -> Html.Attribute msg
opacity_ duration options =
    Transition.properties
        [ Transition.opacity duration options
        ]


fill_ : Transition.Millis -> List Transition.Option -> Html.Attribute msg
fill_ duration options =
    Transition.properties
        [ Transition.property "fill" duration options
        ]
