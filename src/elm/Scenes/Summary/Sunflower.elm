module Scenes.Summary.Sunflower exposing
    ( background
    , hidden
    , visible
    )

import Css.Color as Color exposing (Color)
import Css.Style as Style exposing (Style, opacity, svgStyle, svgStyles)
import Css.Transform as Transform
import Css.Transition as Transition exposing (cubicBezier, delay, easeOut, linear, transition)
import Data.Window as Window exposing (Window)
import Helpers.Svg exposing (..)
import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Views.Flowers.Sunflower as Sunflower
import Views.Landscape.SteepHills as Hills


type Visibility
    = Hidden
    | Visible


visible : Window -> Svg msg
visible =
    view Visible


hidden : Window -> Svg msg
hidden =
    view Hidden


background : Color
background =
    Color.meadowGreen


view : Visibility -> Window -> Svg msg
view visibility window =
    Svg.svg
        [ windowViewBox_ window
        , class "fixed z-1 top-0"
        ]
        [ Svg.g [] <| generateHills visibility window
        , flowers visibility window
        ]


flowers : Visibility -> Window -> Svg msg
flowers visibility window =
    case visibility of
        Hidden ->
            Svg.g [] []

        Visible ->
            Svg.g []
                [ sunflower window 200 500 |> translated 0 -40
                , sunflower window 100 1000 |> translated -100 60
                , sunflower window 100 1500 |> translated 100 60
                ]


sunflower : Window -> Float -> Int -> Svg msg
sunflower window size delay =
    Svg.svg
        [ viewBox_ 0 0 size size
        , x_ <| toFloat window.width / 2
        , y_ <| toFloat window.height / 2 - 50
        , width_ size
        , height_ size
        ]
        [ Sunflower.animated delay ]
        |> translated -(size / 2) -(size / 2)


generateHills : Visibility -> Window -> List (Svg msg)
generateHills visibility window =
    hillsRange window
        |> List.map cycleHillColors
        |> List.indexedMap (\i ( l, r ) -> hills l r (toFloat i * -120) window visibility)
        |> List.reverse


hillsRange : Window -> List Int
hillsRange window =
    case Window.width window of
        Window.Narrow ->
            List.range 0 5

        _ ->
            List.range 0 7


cycleHillColors : Int -> ( Color, Color )
cycleHillColors i =
    case modBy 3 i of
        0 ->
            ( "#2BA765", "#185F39" )

        1 ->
            ( "#1D7145", "#1F8D52" )

        _ ->
            ( "#1D4E34", "#19B562" )


hills : Color -> Color -> Float -> Window -> Visibility -> Svg msg
hills leftColor rightColor offset window visibility =
    let
        y =
            case visibility of
                Hidden ->
                    toFloat <| window.height // 2

                Visible ->
                    offset + 100

        translateY =
            Style.transform [ Transform.translateY y ]
    in
    Svg.g
        [ Style.svgStyles
            [ translateY
            , Transition.transition "transform"
                3000
                [ Transition.cubicBezier 0 0.5 0 1
                , Transition.delay <| round (offset * -2)
                ]
            ]
        ]
        [ Hills.layer window
            0.5
            ( leftColor, [], [] )
            ( rightColor, [], [] )
        ]
