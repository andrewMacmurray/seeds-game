module Views.Icons.RainBank exposing (..)

import Helpers.Css.Style exposing (..)
import Helpers.Css.Transform as Css exposing (translateY)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)


rainBank : Float -> Svg msg
rainBank percentFull =
    let
        fullHeight =
            35.8

        waterLevelOffset =
            (fullHeight / 100) * (100 - percentFull)

        offsetLevelStyles =
            svgStyles
                [ "transition: transform 1.5s ease"
                , "transform:" ++ Css.transform [ translateY waterLevelOffset ]
                ]
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
                ]
                []
            ]
        , Svg.path
            [ rainBankPath
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
                [ Svg.use [ xlinkHref "#water-level", offsetLevelStyles ] []
                ]
            , Svg.path
                [ rainBankPath
                , fill "#26AAE1"
                , mask "url(#rain-bank)"
                ]
                []
            ]
        ]


rainBankFull : Svg msg
rainBankFull =
    Svg.svg
        [ viewBox "0 0 25 36"
        , width "100%"
        , height "100%"
        ]
        [ Svg.path
            [ rainBankPath
            , fill "#26AAE1"
            , transform "translate(-17 .241)"
            ]
            []
        ]


rainBankPath : Attribute msg
rainBankPath =
    d "M29.5 35.2C36.2 35.2 41.6 29.8 41.6 23.1 41.3 17 37.3 9.2 29.5-0.1 21.5 9.3 17.4 17 17.4 23.1 17.4 29.8 22.8 35.2 29.5 35.2Z"
