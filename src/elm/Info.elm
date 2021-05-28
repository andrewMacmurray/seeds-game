module Info exposing
    ( State
    , Visibility(..)
    , content
    , hidden
    , isHidden
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



-- Info


type State content
    = WithContent Visibility content
    | Empty


type Visibility
    = Visible
    | Leaving
    | Hidden



-- Construct


visible : content -> State content
visible =
    WithContent Visible


leaving : State content -> State content
leaving infoWindow =
    case infoWindow of
        WithContent _ content_ ->
            WithContent Leaving content_

        Empty ->
            Empty


hidden : State content
hidden =
    Empty



-- Query


content : State content -> Maybe content
content modal =
    case modal of
        WithContent _ c ->
            Just c

        Empty ->
            Nothing


state : State content -> Visibility
state modal =
    case modal of
        WithContent state_ _ ->
            state_

        Empty ->
            Hidden


isHidden : State content -> Bool
isHidden modal =
    case state modal of
        Hidden ->
            True

        _ ->
            False



-- View


view : State a -> Html msg -> Html msg
view modal content_ =
    case state modal of
        Hidden ->
            span [] []

        Visible ->
            infoContainer_ modal
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ animation "elastic-bounce-in" 2000 [ linear ]
                        , background seedPodGradient
                        , color white
                        , width 380
                        ]
                    ]
                    [ content_ ]
                ]

        Leaving ->
            infoContainer_ modal
                [ div
                    [ class "pa3 br3 tc relative"
                    , style
                        [ background seedPodGradient
                        , color white
                        , width 380
                        , animation "exit-down" 700 [ cubicBezier 0.93 -0.36 0.57 0.96 ]
                        ]
                    ]
                    [ content_ ]
                ]


infoContainer_ : State a -> List (Html msg) -> Html msg
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
