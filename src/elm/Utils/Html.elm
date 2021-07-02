module Utils.Html exposing
    ( none
    , showIfJust
    , square
    )

import Html exposing (Attribute, Html, div, text)
import Utils.Style as Style


none : Html msg
none =
    text ""


showIfJust : (a -> Html msg) -> Maybe a -> Html msg
showIfJust f =
    Maybe.map f >> Maybe.withDefault none


square : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
square size attr =
    div
        (List.append
            [ Style.width size
            , Style.height size
            ]
            attr
        )
