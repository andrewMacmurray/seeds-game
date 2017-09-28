module Views.Tutorial exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


tutorialView =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-999"
        , style [ ( "background-color", "rgba(255, 252, 227, 0.95)" ) ]
        ]
        [ div []
            [ p [] [ text "Connect seed pods to grow seeds" ] ]
        ]
