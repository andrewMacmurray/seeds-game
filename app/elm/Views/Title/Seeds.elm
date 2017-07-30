module Views.Title.Seeds exposing (..)

import Helpers.Style exposing (widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


seeds : Html Msg
seeds =
    div
        [ style [ widthStyle 400 ]
        , class "flex center"
        ]
        (List.map seedSpacing
            [ foxglove
            , lupin
            , sunflower
            , marigold
            , rose
            ]
        )


seedSpacing : Html Msg -> Html Msg
seedSpacing seed =
    div [ class "mh2" ] [ seed ]
