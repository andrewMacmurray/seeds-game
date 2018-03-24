module Views.InfoWindow exposing (..)

import Config.Color exposing (..)
import Data.InfoWindow exposing (..)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


infoContainer : InfoWindow a -> Html msg -> Html msg
infoContainer infoWindow content =
    case infoWindow of
        Hidden ->
            span [] []

        Visible _ ->
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
                        , widthStyle 380
                        ]
                    ]
                    [ content ]
                ]

        Hiding _ ->
            infoContainer_ infoWindow
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ background seedPodGradient
                        , color white
                        , widthStyle 380
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
    case infoWindow of
        Hiding _ ->
            div [ classes [ "touch-disabled", infoContainerBaseClasses ] ]

        _ ->
            div [ class infoContainerBaseClasses ]


infoContainerBaseClasses : String
infoContainerBaseClasses =
    "pointer fixed top-0 bottom-0 left-0 right-0 flex items-center justify-center z-5 ph3"
