module Views.Level.TopBar exposing (..)

import Helpers.Style exposing (px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)


topBar : Model -> Html Msg
topBar model =
    div [ class "w-100 bg-washed-yellow fixed top-0 z-3", style [ ( "height", px model.topBarHeight ) ] ] []
