module Views.InfoWindow exposing (..)

import Data.Color exposing (..)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)


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
                        , animationStyle "elastic-bounce-in 2s linear"
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
                        , animationStyle "exit-down 0.7s cubic-bezier(0.93, -0.36, 0.57, 0.96)"
                        , fillForwards
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
