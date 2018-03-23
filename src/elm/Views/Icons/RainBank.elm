module Views.Icons.RainBank exposing (..)

import Helpers.Css.Style exposing (..)
import Html exposing (Html)
import Svg exposing (Attribute)
import Svg.Attributes exposing (..)


rainBank : Float -> Html msg
rainBank percentFull =
    let
        fullHeight =
            35.8

        waterLevelOffset =
            (fullHeight / 100) * (100 - percentFull)
    in
        Svg.svg
            [ viewBox "0 0 25 36"
            , width "100%"
            , height "100%"
            ]
            [ Svg.defs []
                [ Svg.rect
                    [ height <| toString fullHeight
                    , width "60"
                    , id "water-level"
                    , style "transition: transform 1.5s ease"
                    , transform <| svgTranslate 0 waterLevelOffset
                    ]
                    []
                ]
            , Svg.path
                [ rainbankPath
                , fill "grey"
                , fillOpacity "0.1"
                , transform "translate(-17 -.241)"
                ]
                []
            , Svg.g
                [ fill "none"
                , fillRule "evenodd"
                , transform "translate(-17 .241)"
                ]
                [ Svg.mask
                    [ fill "white"
                    , id "rain-bank"
                    ]
                    [ Svg.use [ xlinkHref "#water-level" ] []
                    ]
                , Svg.path
                    [ rainbankPath
                    , fill "#26AAE1"
                    , mask "url(#rain-bank)"
                    ]
                    []
                ]
            ]


rainbankPath : Attribute msg
rainbankPath =
    d "M29.5 35.2C36.2 35.2 41.6 29.8 41.6 23.1 41.3 17 37.3 9.2 29.5-0.1 21.5 9.3 17.4 17 17.4 23.1 17.4 29.8 22.8 35.2 29.5 35.2Z"
