module Components.Backdrop exposing (backdrop)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)


backdrop : Model -> Html Msg
backdrop model =
    div [ class "fixed w-100 h-100 top-0 left-0 z-0 bg-washed-yellow" ] []
