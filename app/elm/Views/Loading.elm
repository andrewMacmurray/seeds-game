module Views.Loading exposing (..)

import Data.Color exposing (gold)
import Helpers.Style exposing (backgroundColor, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Seed.Twin exposing (sunflower)


loading =
    div
        [ class "w-100 h-100 absolute z-999 top-0 left-0 flex items-center justify-center"
        , style [ backgroundColor gold ]
        ]
        [ div [ style [ widthStyle 50 ] ] [ sunflower ] ]
