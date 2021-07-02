module Element.Icon.SunBank exposing
    ( full
    , icon
    )

import Element exposing (Element)
import Element.Icon as Icon
import Simple.Animation as Animation
import Simple.Transition as Transition
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Utils.Style as Style
import Utils.Svg as Svg
import Utils.Transform as Transform
import Utils.Transition as Transition



-- Sun Bank


type alias Options =
    { percent : Float
    , delay : Animation.Millis
    }


icon : Options -> Element msg
icon options =
    Icon.el
        [ Svg.viewBox_ 0 0 31 37 ]
        [ Svg.defs []
            [ Svg.rect
                [ height (String.fromInt fullHeight)
                , id "sun-level"
                , width "50"
                ]
                []
            ]
        , Svg.g
            [ fill "none"
            , fillRule "evenodd"
            , transform "translate(-11)"
            ]
            [ Svg.path
                [ sunPath
                , fill "#FAD88A"
                , fillOpacity ".634"
                ]
                []
            , Svg.g [ transform "translate(0 20.886)" ]
                [ Svg.mask
                    [ fill "white"
                    , id "sun-bank"
                    ]
                    [ Svg.use
                        [ xlinkHref "#sun-level"
                        , Style.transform [ Transform.translateY (offset options.percent) ]
                        , Transition.transform_ 1500 [ Transition.delay options.delay ]
                        ]
                        []
                    ]
                , Svg.path
                    [ sunPath
                    , fill "#FFAA00"
                    , mask "url(#sun-bank)"
                    , transform "translate(0 -20.886)"
                    ]
                    []
                ]
            ]
        ]


fullHeight : number
fullHeight =
    37


offset : Float -> Float
offset percentFull =
    (fullHeight / 100) * (100 - percentFull)



-- Static


full : Svg msg
full =
    Svg.svg
        [ viewBox "0 0 31 37"
        , width "100%"
        , height "100%"
        ]
        [ Svg.path
            [ sunPath
            , fill "#FFAA00"
            , transform "translate(-11)"
            ]
            []
        ]


sunPath : Attribute msg
sunPath =
    d "M29.5 26.3L26.6 36.4 23.7 26.3C22.8 26 22.1 25.6 21.4 25.1L11.1 28 18.1 20.3C17.9 19.6 17.9 18.9 17.9 18.2 17.9 17.4 18 16.6 18.2 15.9L12.2 8.9 20.8 11.7C21.7 11 22.6 10.4 23.7 10.1L26.6 0 29.5 10.1C30.5 10.4 31.4 11 32.2 11.6L40.2 8.1 34.9 15.8C35.2 16.6 35.3 17.4 35.3 18.2 35.3 18.8 35.2 19.3 35.1 19.9L41.9 27.9 32.2 24.8C31.4 25.4 30.5 26 29.5 26.3Z"
