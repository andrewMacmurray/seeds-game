module Utils.Html exposing
    ( none
    , square
    )

import Html exposing (Attribute, Html, div, text)
import Utils.Html.Style as Style


none : Html msg
none =
    text ""


square : Int -> List (Attribute msg) -> List (Html msg) -> Html msg
square size attr =
    div (List.append [ Style.width size ] attr)
