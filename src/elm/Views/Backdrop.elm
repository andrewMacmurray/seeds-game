module Views.Backdrop exposing (backdrop)

import Config.Color exposing (lightYellow)
import Helpers.Css.Style exposing (backgroundColor, styleAttr)
import Html exposing (..)
import Html.Attributes exposing (..)


backdrop : Html msg
backdrop =
    div
        [ class "fixed w-100 h-100 top-0 left-0 z-0"
        , styleAttr <| backgroundColor lightYellow
        ]
        []
