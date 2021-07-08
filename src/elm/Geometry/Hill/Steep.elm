module Geometry.Hill.Steep exposing
    ( Side
    , Sprite
    , SpriteLayer
    , Sprites
    , behind
    , blankLayer
    , hillPair
    , inFront
    , noSprites
    , plainSide
    , spriteLayers
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
    ( Sprites msg, Sprites msg )


type alias Sprites msg =
    { inner : Maybe (Sprite msg)
    , middle : Maybe (Sprite msg)
    , outer : Maybe (Sprite msg)
    }


type alias Sprite msg =
    { sprites : List (Svg msg)
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


spriteLayers : List (SpriteLayer msg) -> List (SpriteLayer msg)
spriteLayers =
    List.reverse


sprites : Sprites msg -> Sprites msg
sprites =
    identity


plainSide : Color -> Side msg
plainSide color =
    { color = color
    , sprites = noSprites
    }


blankLayer : SpriteLayer msg
blankLayer =
    ( noSprites, noSprites )


noSprites : Sprites msg
noSprites =
    { inner = Nothing
    , middle = Nothing
    , outer = Nothing
    }


inFront : List (Svg msg) -> Sprite msg
inFront svg =
    { sprites = svg
    , position = InFront
    }


behind : List (Svg msg) -> Sprite msg
behind svg =
    { sprites = svg
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


arrangeAroundHill : Hill msg -> List ( Position, List (Shape msg) ) -> List (Shape msg)
arrangeAroundHill options =
    List.foldl arrange [ hill_ options ]


arrange : ( Position, List (Shape msg) ) -> List (Shape msg) -> List (Shape msg)
arrange ( position, h ) sx =
    case position of
        InFront ->
            sx ++ h

        Behind ->
            h ++ sx


sprites_ : Hill msg -> List ( Position, List (Shape msg) )
sprites_ options =
    List.flattenMaybes
        [ Maybe.map (spritesWithPosition options 500) options.sprites.outer
        , Maybe.map (spritesWithPosition options 320) options.sprites.middle
        , Maybe.map (spritesWithPosition options 100) options.sprites.inner
        ]


hill_ : Hill msg -> Shape msg
hill_ options =
    Shape.polygon { fill = options.color } (hillPolygon options)


animate : { a | animation : Maybe Animation } -> Shape msg -> Shape msg
animate options shape =
    options.animation
        |> Maybe.map (\a -> Shape.animate a shape)
        |> Maybe.withDefault shape


spritesWithPosition : Hill msg -> Float -> Sprite msg -> ( Position, List (Shape msg) )
spritesWithPosition options offset sprite_ =
    ( sprite_.position
    , List.indexedMap (toSprite options offset) sprite_.sprites
    )


toSprite : Hill msg -> Float -> Int -> Svg msg -> Shape msg
toSprite options offset i sprite_ =
    Shape.moveDown (options.offset - 75)
        (Shape.placeAt
            (Point2d.along
                (axis options.window)
                (Pixels.pixels (offset + (toFloat i * 40)))
            )
            sprite_
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
