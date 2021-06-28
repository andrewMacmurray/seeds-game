module View.Seed.Mono exposing (greyedOutSeed, rose)

import Css.Color exposing (purple, transparentGray)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg


rose : Svg msg
rose =
    mono purple


greyedOutSeed : Svg msg
greyedOutSeed =
    mono transparentGray


mono : String -> Svg msg
mono bgColor =
    Svg.full
        [ Svg.viewBox_ 0 0 124.5 193.5 ]
        [ Svg.path
            [ fill bgColor
            , d "M121.004,131.87c0,32.104-26.024,58.13-58.13,58.13c-32.1,0-58.123-26.026-58.123-58.13 c0-48.907,58.123-128.797,58.123-128.797S121.004,82.451,121.004,131.87z"
            ]
            []
        ]
