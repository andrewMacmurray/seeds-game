module Element.Layout exposing (fadeIn, view)

import Element exposing (..)
import Element.Animations as Animations
import Element.Palette as Palette
import Element.Text as Text
import Html exposing (Html)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Animated as Animated
import Utils.Element as Element
import Utils.Html.Style as Style



-- View


view : List (Attribute msg) -> Element msg -> Html msg
view attrs =
    Element.layoutWith layoutOptions
        (List.append
            [ width fill
            , height fill
            , Element.style "position" "absolute"
            , Element.style "z-index" "2"
            , Element.class "overflow-y-scroll momentum-scroll"
            , Text.fonts
            , Palette.background1
            ]
            attrs
        )



-- Fade In


fadeIn : List (Attribute msg) -> Element msg -> Html msg
fadeIn attributes el =
    fade
        (Style.center
            [ Style.absolute
            , Style.zIndex 2
            ]
        )
        [ view attributes el ]


fade : List (Html.Attribute msg) -> List (Html msg) -> Html msg
fade =
    Animated.div fade_


fade_ : Animation
fade_ =
    Animations.fadeIn 1000
        [ Animation.linear
        , Animation.delay 200
        ]



-- Internal


layoutOptions : { options : List Option }
layoutOptions =
    { options =
        [ Element.focusStyle
            { borderColor = Nothing
            , backgroundColor = Nothing
            , shadow = Nothing
            }
        ]
    }
