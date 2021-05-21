module Scene.Summary.Chrysanthemum exposing
    ( background
    , hidden
    , visible
    )

import Css.Color as Color exposing (Color)
import Css.Style as Style
import Css.Transform as Transform
import Css.Transition as Transition
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (..)
import View.Flower.Chrysanthemum as Chrysanthemum
import View.Landscape.RollingHills as Hills
import Window exposing (Window)


visible : Window -> Svg msg
visible =
    view Visible


hidden : Window -> Svg msg
hidden =
    view Hidden


background : Color
background =
    Color.purple


type Visibility
    = Visible
    | Hidden


view : Visibility -> Window -> Svg msg
view visibility window =
    Svg.svg
        [ windowViewBox_ window
        , class "fixed z-1 top-0"
        ]
        [ hills "#E268C4" "#F09AEF" -550 1500 visibility window
        , hills red "#9665B4" -440 1200 visibility window
        , hills "#FFA538" "#623D79" -330 900 visibility window
        , hills "#E268C4" "#F09AEF" -220 600 visibility window
        , hills darkPink "#9665B4" -110 300 visibility window
        , hills "#FFA538" "#623D79" 0 0 visibility window
        , flowers visibility window
        ]


red =
    Color.rgb 226 64 64


darkPink =
    Color.rgb 218 37 131


flowers : Visibility -> Window -> Svg msg
flowers visibility window =
    case visibility of
        Hidden ->
            Svg.g [] []

        Visible ->
            Svg.g []
                [ chrysanthemum window 150 1000
                , chrysanthemum window 75 1500 |> translated -100 60
                , chrysanthemum window 75 2000 |> translated 100 60
                ]


hills : Color -> Color -> Float -> Int -> Visibility -> Window -> Svg msg
hills left right offset delay visibility window =
    let
        curve =
            ifNarrow window 1.6 1.3

        y =
            case visibility of
                Hidden ->
                    toFloat <| window.height // 2

                Visible ->
                    offset + 150

        translateStyles d el =
            Svg.g
                [ Style.svgStyle
                    [ Transition.transition "transform"
                        3000
                        [ Transition.cubicBezier 0 0 0 1
                        , Transition.delay d
                        ]
                    , Style.transform [ Transform.translateY y ]
                    ]
                ]
                [ el ]
    in
    Svg.g []
        [ Hills.doubleLayerWithCurve curve window left right |> translateStyles (delay + 500)
        ]


ifNarrow : Window -> a -> a -> a
ifNarrow window a b =
    case Window.width window of
        Window.Narrow ->
            a

        _ ->
            b


chrysanthemum : Window -> Float -> Int -> Svg msg
chrysanthemum window size delay =
    Svg.svg
        [ viewBox_ 0 0 size size
        , x_ <| toFloat window.width / 2
        , y_ <| toFloat window.height / 2 - 50
        , width_ size
        , height_ size
        ]
        [ Chrysanthemum.animated delay ]
        |> translated -(size / 2) -(size / 2)
