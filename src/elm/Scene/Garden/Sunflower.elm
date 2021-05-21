module Scene.Garden.Sunflower exposing (view)

import Element exposing (..)
import Element.Palette as Palette
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Scene.Garden.Flower as Flower
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Triangle2d exposing (Triangle2d)
import Utils.Animated as Animated
import Utils.Geometry exposing (down, mirror)
import Utils.Svg as Svg
import View.Flower.Sunflower as Sunflower
import Window exposing (Window, vh, vw)



-- Description


description : String
description =
    "Sunflowers are native to North America but bloom across the world. During growth their bright yellow flowers turn to face the sun. Their seeds are an important food source for both humans and animals."



-- View


view : Flower.Config msg -> Element msg
view model =
    Flower.view
        { backdrop = Palette.green10
        , hills = hills model.window
        , flowers = flowers
        , description = description
        , isVisible = model.isVisible
        , onHide = model.onHide
        }


flowers : Element msg
flowers =
    row [ centerX ]
        [ el [ width (px 125), alignBottom, moveRight 70 ] (sunflower 2200)
        , el [ width (px 250), moveUp 50 ] (sunflower 2000)
        , el [ width (px 125), alignBottom, moveLeft 70 ] (sunflower 2400)
        ]


sunflower : Animation.Millis -> Element msg
sunflower =
    html << Sunflower.animated


hills : Window -> Svg msg
hills window =
    Svg.window window [] [ genHills window ]


genHills : Window -> Svg msg
genHills window =
    List.range 0 8
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
    { offset = 750 - toFloat (i * 130)
    , delay = i * 300
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
            { duration = 2000
            , options = [ Animation.delay delay ]
            }
            [ P.opacity 0 ]
            [ P.opacity 1 ]
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
