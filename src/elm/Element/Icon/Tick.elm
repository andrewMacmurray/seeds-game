module Element.Icon.Tick exposing (icon)

import Element.Palette as Palette
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg


icon : Svg msg
icon =
    Svg.svg
        [ height "16"
        , viewBox "0 0 16 16"
        , width "16"
        ]
        [ Svg.g
            [ fill "none"
            , fillRule "evenodd"
            ]
            [ Svg.circle
                [ cx "8"
                , cy "8"
                , fill "#5AD962"
                , r "8"
                ]
                []
            , tick
            ]
        ]


tick : Html msg
tick =
    Svg.path
        [ d "M6.7769016,10.1200883 C6.66769935,10.1200883 6.54029671,10.0803407 6.4674952,9.98097165 L5.13886772,8.60967879 C4.95686395,8.41094069 4.95686395,8.11283354 5.12066734,7.91409545 C5.30267111,7.71535735 5.57567675,7.71535735 5.75768052,7.89422164 L6.75870123,8.92765974 L10.034769,5.15163591 C10.1985724,4.95289781 10.4897784,4.95289781 10.6717822,5.1317621 C10.8537859,5.31062638 10.8537859,5.62860734 10.6899826,5.82734543 L7.10450838,9.96109784 C7.0135065,10.0604669 6.90430424,10.1200883 6.7769016,10.1200883 L6.7769016,10.1200883 Z"
        , Svg.fill_ Palette.white
        , fillRule "nonzero"
        ]
        []
