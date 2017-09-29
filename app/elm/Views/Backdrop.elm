module Views.Backdrop exposing (backdrop)

import Data.Color exposing (lightYellow)
import Helpers.Style exposing (backgroundColor)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Model as Level
import Views.Level.Board exposing (handleStop)


backdrop : Level.Model -> Html Level.Msg
backdrop model =
    div
        [ class "fixed w-100 h-100 top-0 left-0 z-0"
        , style [ backgroundColor lightYellow ]
        , handleStop model
        ]
        []
