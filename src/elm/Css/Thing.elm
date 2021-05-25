module Css.Thing exposing (main)

import Element
import Html exposing (div)
import Html.Attributes exposing (style)
import Svg
import Svg.Attributes exposing (d, fill, viewBox, width)


main =
    div []
        [ htmlSeeds
        , elmUiSeeds
        ]


elmUiSeeds =
    Element.layout []
        (Element.row [ Element.width (Element.fill |> Element.maximum 400) ]
            [ Element.html seed
            , Element.html seed
            , Element.html seed
            , Element.html seed
            ]
        )


htmlSeeds =
    div
        [ style "display" "flex"
        , style "max-width" "400px"
        ]
        [ seed
        , seed
        , seed
        , seed
        , seed
        , seed
        ]


seed =
    Svg.svg
        [ width "100%"
        , viewBox "0 0 124.5 193.5"
        ]
        [ Svg.path
            [ fill "rgb(167 29 96)"
            , d "M121.004,131.87c0,32.104-26.024,58.13-58.13,58.13c-32.1,0-58.123-26.026-58.123-58.13 c0-48.907,58.123-128.797,58.123-128.797S121.004,82.451,121.004,131.87z"
            ]
            []
        ]
