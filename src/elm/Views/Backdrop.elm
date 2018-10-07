module Views.Backdrop exposing (backdrop)

import Css.Color exposing (lightYellow)
import Css.Style exposing (backgroundColor, style)
import Html exposing (..)
import Html.Attributes exposing (class)


backdrop : Html msg
backdrop =
    div
        [ style [ backgroundColor lightYellow ]
        , class "fixed w-100 h-100 top-0 left-0 z-0"
        ]
        []
