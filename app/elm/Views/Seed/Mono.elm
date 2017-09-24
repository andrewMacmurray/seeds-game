module Views.Seed.Mono exposing (..)

import Data.Color exposing (brown, darkBrown, purple, transparentGray)
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


rose : Html msg
rose =
    mono purple


greyedOut : Html msg
greyedOut =
    mono transparentGray


mono : String -> Html msg
mono bgColor =
    svg
        [ x "0px"
        , y "0px"
        , width "124.5px"
        , height "193.5px"
        , viewBox "0 0 124.5 193.5"
        , Svg.Attributes.style "width: 100%; height: 100%"
        ]
        [ Svg.path
            [ fill bgColor
            , d "M121.004,131.87c0,32.104-26.024,58.13-58.13,58.13c-32.1,0-58.123-26.026-58.123-58.13 c0-48.907,58.123-128.797,58.123-128.797S121.004,82.451,121.004,131.87z"
            ]
            []
        ]
