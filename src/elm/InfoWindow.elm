module InfoWindow exposing
    ( InfoWindow
    , State(..)
    , content
    , hidden
    , leaving
    , state
    , view
    , visible
    )

import Css.Animation exposing (animation, cubicBezier, ease, linear)
import Css.Color exposing (..)
import Css.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Window



-- Info Window


type InfoWindow content
    = WithContent State content
    | Empty


type State
    = Visible
    | Leaving
    | Hidden



-- Construct


visible : content -> InfoWindow content
visible =
    WithContent Visible


leaving : InfoWindow content -> InfoWindow content
leaving infoWindow =
    case infoWindow of
        WithContent _ content_ ->
            WithContent Leaving content_

        Empty ->
            Empty


hidden : InfoWindow content
hidden =
    Empty



-- Query


content : InfoWindow content -> Maybe content
content infoWindow =
    case infoWindow of
        WithContent _ c ->
            Just c

        Empty ->
            Nothing


state : InfoWindow content -> State
state infoWindow =
    case infoWindow of
        WithContent state_ _ ->
            state_

        Empty ->
            Hidden



-- View


view : InfoWindow a -> Html msg -> Html msg
view infoWindow content_ =
    case state infoWindow of
        Hidden ->
            span [] []

        Visible ->
            infoContainer_ infoWindow
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ animation "elastic-bounce-in" 2000 [ linear ]
                        , background podGradient
                        , color white
                        , width 380
                        ]
                    ]
                    [ content_ ]
                ]

        Leaving ->
            infoContainer_ infoWindow
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ background podGradient
                        , color white
                        , width 380
                        , animation "exit-down" 700 [ cubicBezier 0.93 -0.36 0.57 0.96 ]
                        ]
                    ]
                    [ content_ ]
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
    case state infoWindow of
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
