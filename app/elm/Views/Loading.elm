module Views.Loading exposing (..)

import Data.Color exposing (gold)
import Helpers.Style exposing (backgroundColor, classes, transitionStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Seed.Twin exposing (sunflower)


loadingScreen : Model -> Html Msg
loadingScreen model =
    div
        [ class <|
            classes
                [ "w-100 h-100 absolute z-999 top-0 left-0 flex items-center justify-center"
                , transitionClasses model
                ]
        , style
            [ backgroundColor gold
            , transitionStyle "0.5s ease"
            ]
        ]
        [ div [ style [ widthStyle 50 ] ] [ sunflower ] ]


transitionClasses : Model -> String
transitionClasses model =
    if model.transitioning then
        "o-100"
    else
        "o-0 touch-disabled"
