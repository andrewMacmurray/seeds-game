module Views.InfoWindow exposing (infoContainer, infoContainerBaseClasses, infoContainer_)

import Config.Color exposing (..)
import Config.Scale as ScaleConfig
import Data.InfoWindow exposing (..)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style as Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)


infoContainer : InfoWindow a -> Html msg -> Html msg
infoContainer infoWindow content =
    if isHidden infoWindow then
        span [] []

    else if isVisible infoWindow then
        infoContainer_ infoWindow
            [ div
                [ class "pa3 br3 tc relative"
                , style
                    [ background seedPodGradient
                    , color white
                    , animationStyle
                        { name = "elastic-bounce-in"
                        , duration = 2000
                        , timing = Linear
                        }
                    , width 380
                    ]
                ]
                [ content ]
            ]

    else
        infoContainer_ infoWindow
            [ div
                [ class "pa3 br3 tc relative"
                , style
                    [ background seedPodGradient
                    , color white
                    , width 380
                    , animationStyle
                        { name = "exit-down"
                        , duration = 700
                        , timing = CubicBezier 0.93 -0.36 0.57 0.96
                        }
                    ]
                ]
                [ content ]
            ]


infoContainer_ : InfoWindow a -> List (Html msg) -> Html msg
infoContainer_ infoWindow =
    let
        containerStyles =
            style
                [ paddingLeft ScaleConfig.windowPadding
                , paddingRight ScaleConfig.windowPadding
                , animateEase "fade-in" 100
                ]
    in
    if isLeaving infoWindow then
        div
            [ classes
                [ "touch-disabled"
                , infoContainerBaseClasses
                ]
            , containerStyles
            ]

    else
        div
            [ classes [ infoContainerBaseClasses ]
            , containerStyles
            ]


infoContainerBaseClasses : String
infoContainerBaseClasses =
    "pointer fixed top-0 bottom-0 left-0 right-0 flex items-center justify-center z-5"
