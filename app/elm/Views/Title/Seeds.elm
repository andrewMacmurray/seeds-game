module Views.Title.Seeds exposing (..)

import Helpers.Style exposing (maxWidth)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


seeds : Html Msg
seeds =
    div
        [ style [ maxWidth 450 ]
        , class "flex center ph3"
        ]
        (List.map seedSpacing
            [ foxglove
            , marigold
            , sunflower
            , lupin
            , rose
            ]
        )


seedSpacing : Html Msg -> Html Msg
seedSpacing seed =
    div [ class "mh2" ] [ seed ]
