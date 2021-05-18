module Scene.Garden.Sunflower exposing (view)

import Element exposing (..)
import Element.Animations as Animations
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Element.Transition as Transition
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Triangle2d exposing (Triangle2d)
import Utils.Animated as Animated
import Utils.Element as Element
import Utils.Geometry exposing (down, mirror)
import Utils.Svg as Svg
import View.Flower.Sunflower as Sunflower
import View.Icon.Cross as Cross
import Window exposing (Window, vh, vw)



-- Model


type alias Model msg =
    { onHide : msg
    , visible : Bool
    , window : Window
    }



-- Description


description_ : String
description_ =
    "Sunflowers are native to North America but bloom across the world. During growth their bright yellow flowers turn to face the sun. Their seeds are an important food source for both humans and animals."



-- View


view : Model msg -> Element msg
view model =
    column
        [ width fill
        , height fill
        , behindContent backdrop
        , behindContent (html (hills model.window))
        , inFront (hideButton model)
        , Element.visibleIf model.visible
        , Transition.alpha 1000 []
        ]
        [ flowersAndDescription
        ]


flowersAndDescription : Element msg
flowersAndDescription =
    column
        [ centerX
        , centerY
        , paddingXY Scale.medium 0
        , spacing Scale.medium
        , width (fill |> maximum 500)
        ]
        [ row [ centerX ]
            [ el [ width (px 125), alignBottom, moveRight 70 ] (sunflower 2200)
            , el [ width (px 250), moveUp 50 ] (sunflower 2000)
            , el [ width (px 125), alignBottom, moveLeft 70 ] (sunflower 2400)
            ]
        , description
        ]


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


description : Element msg
description =
    Animated.el fadeText [] (Text.paragraph [ Text.color Palette.white ] description_)


sunflower : Animation.Millis -> Element msg
sunflower =
    html << Sunflower.animated


backdrop : Element msg
backdrop =
    Animated.el fadeBackground
        [ width fill
        , height fill
        , Background.color Palette.green10
        ]
        none


fadeText : Animation
fadeText =
    Animations.fadeIn 1000 [ Animation.delay 3500 ]


fadeBackground : Animation
fadeBackground =
    Animations.fadeIn 3000 [ Animation.linear ]


hills : Window -> Svg msg
hills window =
    Svg.window window [] [ genHills window ]


genHills : Window -> Svg msg
genHills window =
    List.range 0 7
        |> List.map cycleHillColors
        |> List.indexedMap toHillConfig
        |> List.map (toHillPair window)
        |> List.concat
        |> List.reverse
        |> Svg.g []


toHillPair : Window -> HillConfig -> List (Svg msg)
toHillPair window config =
    [ fadeInHill config.delay
        (mirrored
            { offset = config.offset
            , color = config.left
            }
            window
        )
    , fadeInHill config.delay
        (hill
            { offset = config.offset
            , color = config.right
            }
            window
        )
    ]


type alias HillConfig =
    { delay : Animation.Millis
    , offset : Float
    , left : Color
    , right : Color
    }


toHillConfig : Int -> ( Color, Color ) -> HillConfig
toHillConfig i ( left, right ) =
    { offset = 750 - toFloat (i * 150)
    , delay = i * 220
    , left = left
    , right = right
    }


cycleHillColors : Int -> ( Color, Color )
cycleHillColors i =
    case modBy 3 i of
        0 ->
            ( Palette.green8, Palette.green3 )

        1 ->
            ( Palette.green4, Palette.green2 )

        _ ->
            ( Palette.green1, Palette.green6 )


fadeInHill : Animation.Millis -> Svg msg -> Svg msg
fadeInHill delay h =
    Animated.g
        (Animation.fromTo
            { duration = 1500
            , options = [ Animation.delay delay ]
            }
            [ P.opacity 0, P.y 0 ]
            [ P.opacity 1, P.y 0 ]
        )
        []
        [ h ]


mirrored : { a | offset : Float, color : Color } -> Window -> Svg msg
mirrored options window =
    mirror window (hill options window)


hill : { a | offset : Float, color : Element.Color } -> Window -> Svg msg
hill { offset, color } window =
    Svg.triangle2d [ Svg.fill_ color ] (hill_ offset window)


hill_ : Float -> Window -> Triangle2d Pixels coordinates
hill_ y window =
    Triangle2d.translateBy (down y)
        (Triangle2d.from
            (Point2d.pixels 0 0)
            (Point2d.pixels (vw window / 2 + 600) (vh window))
            (Point2d.pixels 0 (vh window))
        )
