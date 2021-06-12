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


type alias FadeInOptions msg =
    { duration : Animation.Millis
    , attributes : List (Attribute msg)
    }


fadeIn : FadeInOptions msg -> Element msg -> Html msg
fadeIn options el =
    fade options.duration
        (Style.center
            [ Style.absolute
            , Style.zIndex 2
            ]
        )
        [ view options.attributes el ]


fade : Animation.Millis -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
fade =
    fade_ >> Animated.div


fade_ : Animation.Millis -> Animation
fade_ duration =
    Animations.fadeIn duration
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
