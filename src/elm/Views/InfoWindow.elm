module Views.InfoWindow exposing (infoContainer, infoContainerBaseClasses, infoContainer_)

import Css.Animation exposing (animation, cubicBezier, ease, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import InfoWindow exposing (..)
import Window


infoContainer : InfoWindow a -> Html msg -> Html msg
infoContainer infoWindow content =
    case InfoWindow.state infoWindow of
        Hidden ->
            span [] []

        Visible ->
            infoContainer_ infoWindow
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ animation "elastic-bounce-in" 2000 [ linear ]
                        , background seedPodGradient
                        , color white
                        , width 380
                        ]
                    ]
                    [ content ]
                ]

        Leaving ->
            infoContainer_ infoWindow
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ background seedPodGradient
                        , color white
                        , width 380
                        , animation "exit-down" 700 [ cubicBezier 0.93 -0.36 0.57 0.96 ]
                        ]
                    ]
                    [ content ]
                ]


infoContainer_ : InfoWindow a -> List (Html msg) -> Html msg
infoContainer_ infoWindow =
    let
        containerStyles =
            style
                [ paddingLeft Window.padding
                , paddingRight Window.padding
                , animation "fade-in" 100 [ ease ]
                ]
    in
    case InfoWindow.state infoWindow of
        Leaving ->
            div
                [ classes
                    [ "touch-disabled"
                    , infoContainerBaseClasses
                    ]
                , containerStyles
                ]

        _ ->
            div
                [ classes [ infoContainerBaseClasses ]
                , containerStyles
                ]


infoContainerBaseClasses : String
infoContainerBaseClasses =
    "pointer fixed top-0 bottom-0 left-0 right-0 flex items-center justify-center z-5"
