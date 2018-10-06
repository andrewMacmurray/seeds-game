module Views.InfoWindow exposing (infoContainer, infoContainerBaseClasses, infoContainer_)

import Config.Scale as ScaleConfig
import Css.Animation exposing (animation, cubicBezier, ease, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Timing exposing (..)
import Data.InfoWindow exposing (..)
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
                , styles
                    [ animation "elastic-bounce-in" 2000 |> linear
                    , [ background seedPodGradient
                      , color white
                      , width 380
                      ]
                    ]
                ]
                [ content ]
            ]

    else
        infoContainer_ infoWindow
            [ div
                [ class "pa3 br3 tc relative"
                , styles
                    [ [ background seedPodGradient
                      , color white
                      , width 380
                      ]
                    , animation "exit-down" 700 |> cubicBezier 0.93 -0.36 0.57 0.96
                    ]
                ]
                [ content ]
            ]


infoContainer_ : InfoWindow a -> List (Html msg) -> Html msg
infoContainer_ infoWindow =
    let
        containerStyles =
            styles
                [ [ paddingLeft ScaleConfig.windowPadding
                  , paddingRight ScaleConfig.windowPadding
                  ]
                , animation "fade-in" 100 |> ease
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
