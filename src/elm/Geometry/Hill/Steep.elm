module Geometry.Hill.Steep exposing
    ( Side
    , Sprite
    , SpriteLayer
    , Sprites
    , behind
    , hillPair
    , inFront
    , noSprites
    , plainSide
    , sprites
    )

import Axis2d exposing (Axis2d)
import Direction2d
import Element exposing (..)
import Geometry.Shape as Shape exposing (Shape)
import Pixels exposing (Pixels)
import Point2d exposing (Point2d)
import Polygon2d exposing (Polygon2d)
import Simple.Animation exposing (Animation)
import Svg exposing (Svg)
import Utils.Geometry exposing (down)
import Utils.List as List
import Window exposing (Window, vh, vw)



-- Steep Hill


type alias Options msg =
    { window : Window
    , offset : Float
    , left : Side msg
    , right : Side msg
    , animation : Maybe Animation
    }


type alias Side msg =
    { color : Color
    , sprites : Sprites msg
    }


type alias SpriteLayer msg =
    { left : Sprites msg
    , right : Sprites msg
    }


type alias Sprites msg =
    { inner : Maybe (Sprite msg)
    , middle : Maybe (Sprite msg)
    , outer : Maybe (Sprite msg)
    }


type alias Sprite msg =
    { svg : Svg msg
    , position : Position
    }


type Position
    = InFront
    | Behind


type alias Hill msg =
    { offset : Float
    , color : Color
    , sprites : Sprites msg
    , window : Window
    , animation : Maybe Animation
    }



-- Sprites


sprites : Sprites msg -> Sprites msg
sprites =
    identity


plainSide : Color -> Side msg
plainSide color =
    { color = color
    , sprites = noSprites
    }


noSprites : Sprites msg
noSprites =
    { inner = Nothing
    , middle = Nothing
    , outer = Nothing
    }


inFront : Svg msg -> Sprite msg
inFront svg =
    { svg = svg
    , position = InFront
    }


behind : Svg msg -> Sprite msg
behind svg =
    { svg = svg
    , position = Behind
    }



-- Shape


hillPair : Options msg -> List (Shape msg)
hillPair options =
    [ hill
        { offset = options.offset
        , color = options.right.color
        , sprites = options.right.sprites
        , window = options.window
        , animation = options.animation
        }
    , mirrored
        { offset = options.offset
        , color = options.left.color
        , sprites = options.left.sprites
        , window = options.window
        , animation = options.animation
        }
    ]


mirrored : Hill msg -> Shape msg
mirrored =
    Shape.mirror << hill


hill : Hill msg -> Shape msg
hill options =
    sprites_ options
        |> arrangeAroundHill options
        |> Shape.group
        |> animate options


arrangeAroundHill : Hill msg -> List ( Position, Shape msg ) -> List (Shape msg)
arrangeAroundHill options =
    List.foldl arrange [ hill_ options ]


arrange : ( Position, Shape msg ) -> List (Shape msg) -> List (Shape msg)
arrange ( position, h ) xs =
    case position of
        InFront ->
            xs ++ [ h ]

        Behind ->
            h :: xs


sprites_ : Hill msg -> List ( Position, Shape msg )
sprites_ options =
    List.flattenMaybes
        [ Maybe.map (sprite options 500) options.sprites.outer
        , Maybe.map (sprite options 300) options.sprites.middle
        , Maybe.map (sprite options 150) options.sprites.inner
        ]


hill_ : Hill msg -> Shape msg
hill_ options =
    Shape.polygon { fill = options.color } (hillPolygon options)


animate : { a | animation : Maybe Animation } -> Shape msg -> Shape msg
animate options shape =
    options.animation
        |> Maybe.map (\a -> Shape.animate a shape)
        |> Maybe.withDefault shape


sprite : Hill msg -> Float -> Sprite msg -> ( Position, Shape msg )
sprite options offset sprite_ =
    ( sprite_.position
    , Shape.moveDown (options.offset - 75)
        (Shape.placeAt
            (Point2d.along
                (axis options.window)
                (Pixels.pixels offset)
            )
            sprite_.svg
        )
    )


hillPolygon : Hill msg -> Polygon2d Pixels coordinates
hillPolygon options =
    Polygon2d.translateBy (down options.offset)
        (Polygon2d.singleLoop
            [ p1 options.window
            , p2 options.window
            , Point2d.translateBy (down hillHeight) (p2 options.window)
            , Point2d.translateBy (down hillHeight) (p1 options.window)
            ]
        )


hillHeight : number
hillHeight =
    300


p1 : Window -> Point2d Pixels coordinates
p1 window =
    Point2d.along (axis window) (Pixels.pixels (vw window))


p2 : Window -> Point2d Pixels coordinates
p2 window =
    Point2d.along (axis window) (Pixels.pixels -(vw window))


axis : Window -> Axis2d Pixels coordinates
axis w =
    Axis2d.withDirection
        (Direction2d.degrees -26)
        (Point2d.pixels (vw w / 2) (vh w - 450))
