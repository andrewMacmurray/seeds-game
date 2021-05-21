module Scene.Garden.Flower exposing (Config, view)

import Element exposing (..)
import Element.Animations as Animations
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Element.Transition as Transition
import Simple.Animation as Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Element as Element
import View.Icon.Cross as Cross
import Window exposing (Window)



-- Model


type alias Model msg =
    { backdrop : Color
    , hills : Svg msg
    , flowers : Element msg
    , description : String
    , onHide : msg
    , isVisible : Bool
    }


type alias Config msg =
    { onHide : msg
    , window : Window
    , isVisible : Bool
    }



-- View


view : Model msg -> Element msg
view model =
    column
        [ width fill
        , height fill
        , behindContent (backdrop model.backdrop)
        , behindContent (html model.hills)
        , inFront (hideButton model)
        , Element.visibleIf model.isVisible
        , Transition.alpha 1000 []
        ]
        [ flowersAndDescription model
        ]


backdrop : Color -> Element msg
backdrop color =
    Animated.el fadeBackground
        [ width fill
        , height fill
        , Background.color color
        ]
        none


hideButton : Model msg -> Element msg
hideButton model =
    el
        [ onClick model.onHide
        , alignTop
        , alignRight
        , width (px 70)
        , pointer
        , padding Scale.medium
        ]
        (html Cross.icon)


flowersAndDescription : Model msg -> Element msg
flowersAndDescription model =
    column
        [ centerX
        , centerY
        , paddingXY Scale.medium 0
        , spacing Scale.medium
        , width (fill |> maximum 500)
        ]
        [ model.flowers
        , description model.description
        ]


description : String -> Element msg
description description_ =
    Animated.el fadeText [] (Text.paragraph [ Text.color Palette.white ] description_)


fadeText : Animation
fadeText =
    Animations.fadeIn 1000 [ Animation.delay 3500 ]


fadeBackground : Animation
fadeBackground =
    Animations.fadeIn 3000 [ Animation.linear ]
