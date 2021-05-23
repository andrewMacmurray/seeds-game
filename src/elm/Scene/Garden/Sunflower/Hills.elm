module Scene.Garden.Sunflower.Hills exposing (shape)

import Axis2d
import Direction2d
import Element exposing (..)
import Element.Palette as Palette
import Pixels exposing (Pixels)
import Point2d
import Polygon2d exposing (Polygon2d)
import Shape exposing (Shape)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Hills


shape : Window -> Shape
shape window =
    List.range 0 5
        |> List.map cycleHillColors
        |> List.indexedMap toHillConfig
        |> List.map (toHillPair window)
        |> List.concat
        |> List.reverse
        |> Shape.group


toHillPair : Window -> HillConfig -> List Shape
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
    { offset = 750 - toFloat (i * 180)
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


mirrored : { offset : Float, color : Color } -> Window -> Shape
mirrored options window =
    Shape.mirror (hill options window)


hill : { offset : Float, color : Element.Color } -> Window -> Shape
hill { offset, color } window =
    Shape.polygon { fill = color } (hill_ offset window)


hill_ : Float -> Window -> Polygon2d Pixels coordinates
hill_ y window =
    let
        ax =
            axis window

        p1 =
            Point2d.along ax (Pixels.pixels (toFloat window.width))

        p2 =
            Point2d.along ax (Pixels.pixels (toFloat -window.width))
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
        (Direction2d.degrees -26)
        (Point2d.pixels (vw w / 2) (vh w - 450))
