module Element.Backdrop.SteepValley exposing
    ( animated
    , static
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Palette as Palette
import Geometry.Hill.Steep as Steep
import Geometry.Shape as Shape exposing (Shape)
import Simple.Animation as Animation exposing (Animation)
import Utils.Cycle as Cycle
import Window exposing (Window)



-- Hills


type alias AnimatedOptions =
    { window : Window
    , delay : Animation.Millis
    }


type alias StaticOptions =
    { window : Window
    }


type alias Colors =
    Cycle.Three Colors_


type alias Colors_ =
    ( Color, Color )


type alias Options_ =
    { window : Window
    , colors : Colors
    , animation : HillsAnimation
    }


type HillsAnimation
    = None
    | Animated Animation.Millis


maxHills : number
maxHills =
    6



-- Colors


greens : Colors
greens =
    { one = ( Palette.green8, Palette.green3 )
    , two = ( Palette.green4, Palette.green2 )
    , three = ( Palette.green1, Palette.green6 )
    }



-- View


animated : AnimatedOptions -> Shape msg
animated options =
    shape_
        { window = options.window
        , colors = greens
        , animation = Animated options.delay
        }


static : StaticOptions -> Shape msg
static options =
    shape_
        { window = options.window
        , colors = greens
        , animation = None
        }


shape_ : Options_ -> Shape msg
shape_ options =
    List.range 0 (maxHills - 1)
        |> List.map (cycleColors options)
        |> List.indexedMap toHillConfig
        |> List.map (toHillPair options)
        |> List.concat
        |> List.reverse
        |> Shape.group
        |> Shape.moveUp 50


cycleColors : Options_ -> Int -> ( Color, Color )
cycleColors options =
    Cycle.three options.colors


type alias HillConfig =
    { order : Int
    , offset : Float
    , left : Color
    , right : Color
    }


toHillConfig : Int -> ( Color, Color ) -> HillConfig
toHillConfig i ( left, right ) =
    { order = i
    , offset = 750 - toFloat (i * 180)
    , left = left
    , right = right
    }


toHillPair : Options_ -> HillConfig -> List (Shape msg)
toHillPair options config =
    Steep.hillPair
        { window = options.window
        , offset = config.offset
        , left = Steep.plainSide config.left
        , right = Steep.plainSide config.right
        , animation = animation options config
        }



-- Animate


animation : Options_ -> HillConfig -> Maybe Animation
animation options config =
    case options.animation of
        Animated delay ->
            Just (fadeIn delay config)

        None ->
            Nothing


fadeIn : Animation.Millis -> HillConfig -> Animation
fadeIn delay config =
    Animations.fadeIn 500
        [ Animation.delay (fadeHillDelay delay config)
        ]


fadeHillDelay : Animation.Millis -> HillConfig -> Animation.Millis
fadeHillDelay delay config =
    delay + (config.order * 150)
