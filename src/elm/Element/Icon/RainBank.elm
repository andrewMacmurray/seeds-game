module Element.Icon.RainBank exposing
    ( full
    , icon
    )

import Css.Style as Style exposing (svgStyle)
import Css.Transform exposing (translateY)
import Css.Transition exposing (transitionAll)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)



-- Rain Bank


icon : Float -> Svg msg
icon percentFull =
    Svg.svg
        [ viewBox "0 0 25 36"
        , width "100%"
        , height "100%"
        ]
        [ Svg.defs []
            [ Svg.rect
                [ height (String.fromFloat fullHeight)
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
                [ Svg.use
                    [ xlinkHref "#water-level"
                    , offsetLevelStyles percentFull
                    ]
                    []
                ]
            , Svg.path
                [ rainBankPath
                , fill "#26AAE1"
                , mask "url(#rain-bank)"
                ]
                []
            ]
        ]


fullHeight : Float
fullHeight =
    35.8


offsetLevelStyles : Float -> Attribute msg
offsetLevelStyles percentFull =
    svgStyle
        [ transitionAll 1500 []
        , Style.transform [ translateY (offset percentFull) ]
        ]


offset : Float -> Float
offset percentFull =
    (fullHeight / 100) * (100 - percentFull)



-- Static


full : Svg msg
full =
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
