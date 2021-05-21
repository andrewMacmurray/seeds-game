module Scene.Garden.Sunflower exposing (hills, view)

import Axis2d
import Direction2d
import Element exposing (..)
import Element.Palette as Palette
import Geometry.Svg as Svg
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Polygon2d
import Scene.Garden.Flower as Flower
import Svg exposing (Svg)
import Triangle2d exposing (Triangle2d)
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
        [ el [ width (px 125), alignBottom, moveRight 70 ] sunflower
        , el [ width (px 250), moveUp 50 ] sunflower
        , el [ width (px 125), alignBottom, moveLeft 70 ] sunflower
        ]


sunflower =
    html Sunflower.static


hills : Window -> Svg msg
hills window =
    Svg.window window [] [ genHills window ]


genHills : Window -> Svg msg
genHills window =
    List.range 0 4
        |> List.map cycleHillColors
        |> List.indexedMap toHillConfig
        |> List.map (toHillPair window)
        |> List.concat
        |> List.reverse
        |> Svg.g []


toHillPair : Window -> HillConfig -> List (Svg msg)
toHillPair window config =
    [ hill
        { offset = config.offset
        , color = config.right
        }
        window
    , mirrored
        { offset = config.offset
        , color = config.left
        }
        window
    ]


type alias HillConfig =
    { offset : Float
    , left : Color
    , right : Color
    }


toHillConfig : Int -> ( Color, Color ) -> HillConfig
toHillConfig i ( left, right ) =
    { offset = 750 - toFloat (i * 200)
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


mirrored : { a | offset : Float, color : Color } -> Window -> Svg msg
mirrored options window =
    mirror window (hill options window)


hill : { a | offset : Float, color : Element.Color } -> Window -> Svg msg
hill { offset, color } window =
    Svg.polygon2d [ Svg.fill_ color ] (hill2 offset window)


hill_ : Float -> Window -> Triangle2d Pixels coordinates
hill_ y window =
    Triangle2d.translateBy (down y)
        (Triangle2d.from
            (Point2d.pixels 0 0)
            (Point2d.pixels (vw window / 2 + 600) (vh window))
            (Point2d.pixels 0 (vh window))
        )



-- Hills 2


hill2 y window =
    let
        ax =
            axis window

        p1 =
            Point2d.along ax (Pixels.pixels 1000)

        p2 =
            Point2d.along ax (Pixels.pixels -1000)
    in
    Polygon2d.translateBy (down y)
        (Polygon2d.singleLoop
            [ p1
            , p2
            , p2 |> Point2d.translateBy (down 300)
            , p1 |> Point2d.translateBy (down 300)
            ]
        )


axis w =
    Axis2d.withDirection
        (Direction2d.degrees -30)
        (Point2d.pixels (vw w / 2) (vh w - 450))
