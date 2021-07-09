module Element.Legacy.Landscape.RollingHills exposing
    ( Sprite
    , doubleLayer
    , sprite
    )

import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Style as Style
import Utils.Svg as Svg exposing (..)
import Utils.Transform as Transform
import Window exposing (Window)


type alias Sprite msg =
    { angle : Float
    , adjustY : Float
    , element : Svg msg
    }


doubleLayer : Window -> ( String, List (Sprite msg) ) -> ( String, List (Sprite msg) ) -> Svg msg
doubleLayer =
    doubleLayerWithCurve_ 1


doubleLayerWithCurve_ : Float -> Window -> ( String, List (Sprite msg) ) -> ( String, List (Sprite msg) ) -> Svg msg
doubleLayerWithCurve_ curve window ( leftColor, leftSprites ) ( rightColor, rightSprites ) =
    Svg.g_ []
        [ hillFullScreen window
            { color = leftColor
            , sprites = leftSprites
            , side = Left
            , curve = curve
            }
        , hillFullScreen window
            { color = rightColor
            , sprites = rightSprites
            , side = Right
            , curve = curve
            }
        ]


sprite : Float -> Float -> Svg msg -> Sprite msg
sprite =
    Sprite


type alias Hill msg =
    { color : String
    , sprites : List (Sprite msg)
    , side : Side
    , curve : Float
    }


type Side
    = Left
    | Right


hillFullScreen : Window -> Hill msg -> Svg msg
hillFullScreen window hillConfig =
    let
        w =
            toFloat window.width

        h =
            toFloat window.height

        cx =
            sideToCx window hillConfig.side

        cy =
            h / 2

        r =
            w / hillConfig.curve

        elements =
            List.map (renderElement cx cy r) hillConfig.sprites
    in
    Svg.svg
        [ viewBox_ 0 0 w 3000
        , width_ w
        , height_ 3000
        ]
        (hill hillConfig.color r cx cy :: elements)


renderElement : Float -> Float -> Float -> Sprite msg -> Svg msg
renderElement cx cy r elementConfig =
    let
        a =
            degrees <| elementConfig.angle - 90

        ( x, y ) =
            ( cx + r * cos a
            , cy + r * sin a
            )
    in
    translated x (y + r + elementConfig.adjustY) elementConfig.element


sideToCx : Window -> Side -> Float
sideToCx window side =
    case side of
        Left ->
            0

        Right ->
            toFloat window.width


hill : String -> Float -> Float -> Float -> Svg msg
hill color r cx cy =
    Svg.circle
        [ cx_ cx
        , cy_ cy
        , r_ r
        , fill color
        , Style.transform [ Transform.translateY r ]
        ]
        []
