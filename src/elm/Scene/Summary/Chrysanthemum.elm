module Scene.Summary.Chrysanthemum exposing
    ( background
    , flowers
    , hills
    , hills_
    )

import Axis2d exposing (Axis2d)
import Circle2d exposing (Circle2d)
import Direction2d
import Element exposing (..)
import Element.Animations as Animations
import Element.Flower.Chrysanthemum as Chrysanthemum
import Element.Palette as Palette
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Scene.Garden.Chrysanthemum.Sprites as Bee
import Simple.Animation as Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Geometry exposing (down)
import Window exposing (Window, vh, vw)



-- Background


background : Element.Color
background =
    Palette.purple10



-- Flowers


flowers : Element msg
flowers =
    row [ centerX, centerY ]
        [ el
            [ moveDown 25
            , moveRight 0
            , bee { x = 0, y = -16, delay = 1600 }
            ]
            (flower { size = 75, delay = 300 })
        , el
            [ moveUp 45
            , bee { x = 0, y = 15, delay = 0 }
            , bee { x = -25, y = -5, delay = 500 }
            , bee { x = 25, y = -25, delay = 700 }
            ]
            (flower { size = 125, delay = 0 })
        , el
            [ moveDown 25
            , moveLeft 0
            , bee { x = 0, y = -5, delay = 1200 }
            ]
            (flower { size = 75, delay = 600 })
        ]


type alias BeeOptions =
    { x : Float
    , y : Float
    , delay : Animation.Millis
    }


bee : BeeOptions -> Attribute msg
bee options =
    inFront
        (el
            [ centerX
            , centerY
            , moveRight options.x
            , moveDown options.y
            ]
            (Bee.bee { delay = options.delay + 3000 })
        )


type alias FlowerOptions =
    { size : Int
    , delay : Animation.Millis
    }


flower : FlowerOptions -> Element msg
flower options =
    el [ width (px options.size) ] (html (Chrysanthemum.animated (1000 + options.delay)))



-- Hills


hills : Window -> Svg msg
hills window =
    Shape.window window [] (hills_ window)


hills_ : Window -> Shape
hills_ window =
    List.range 0 5
        |> List.map (cycleHills >> hillTrio window)
        |> Shape.group
        |> Shape.moveDown (sceneOffset window)


sceneOffset : Window -> number
sceneOffset =
    Window.whenNarrow 400 350


cycleHills : Int -> HillTrio
cycleHills i =
    case modBy 4 i of
        0 ->
            { order = i
            , offset = toOffset i
            , left = Palette.purple5
            , middle = Palette.purple1
            , right = Palette.purple5
            }

        1 ->
            { order = i
            , offset = toOffset i
            , left = Palette.purple6
            , middle = Palette.purple2
            , right = Palette.purple6
            }

        2 ->
            { order = i
            , offset = toOffset i
            , left = Palette.purple8
            , middle = Palette.purple1
            , right = Palette.purple8
            }

        _ ->
            { order = i
            , offset = toOffset i
            , left = Palette.purple9
            , middle = Palette.purple2
            , right = Palette.purple9
            }


toOffset : Int -> Float
toOffset i =
    -430 + toFloat i * 180


type alias HillTrio =
    { order : Int
    , offset : Float
    , left : Color
    , middle : Color
    , right : Color
    }


hillTrio : Window -> HillTrio -> Shape
hillTrio window { offset, right, middle, left, order } =
    Shape.group
        [ roundHill offset right window
            |> animateHill order 400
        , Shape.mirror (roundHill offset left window)
            |> animateHill order 400
        , middleHill offset window middle
            |> animateHill order 0
        ]


animateHill : Int -> Animation.Millis -> Shape -> Shape
animateHill order delay =
    Shape.animate
        (Animations.fadeIn 600
            [ Animation.delay (800 + (150 * (5 - order) + delay))
            ]
        )


middleHill : Float -> Window -> Color -> Shape
middleHill y w c =
    Shape.circle { fill = c } (middleHill_ y w)


roundHill : Float -> Color -> Window -> Shape
roundHill y color window =
    Shape.circle { fill = color } (roundHill_ y window)


middleHill_ : Float -> Window -> Circle2d Pixels coordinates
middleHill_ y w =
    Circle2d.translateBy (down y)
        (Circle2d.atPoint
            (Point2d.pixels (vw w / 2) (vh w - 60))
            (Pixels.pixels 680)
        )


roundHill_ : Float -> Window -> Circle2d Pixels coordinates
roundHill_ y w =
    Circle2d.translateBy (down (roundHillOffset y w))
        (Circle2d.atPoint
            (point w)
            (Pixels.pixels (roundHillSize w))
        )


roundHillOffset : number -> Window -> number
roundHillOffset y =
    Window.whenNarrow (y - 50) y


roundHillSize : Window -> Float
roundHillSize w =
    clamp 385 1800 (vw w / 2)


point : Window -> Point2d Pixels coordinates
point w =
    Point2d.along (axis w) (Pixels.pixels (vw w / 2))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees (vw w / 50))
        (Point2d.pixels (vw w / 2) (vh w / 2))
