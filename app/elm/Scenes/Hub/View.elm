module Scenes.Hub.View exposing (..)

import Dict
import Helpers.Style exposing (backgroundColor, color, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Scenes.Level.Model exposing (SeedType(..))
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


hub : Model -> Html Msg
hub model =
    div [ class "w-100 relative z-5" ]
        (model.hubData
            |> Dict.toList
            |> List.reverse
            |> List.map renderWorld
        )


renderWorld : ( Int, WorldData ) -> Html Msg
renderWorld ( _, worldData ) =
    div [ style [ backgroundColor worldData.background ], class "pa5" ]
        [ div
            [ style [ widthStyle 300 ], class "center" ]
            (worldData.levels
                |> Dict.toList
                |> List.reverse
                |> List.map (renderLevel worldData)
            )
        ]


renderLevel : WorldData -> ( Int, LevelData ) -> Html Msg
renderLevel worldData ( number, _ ) =
    div
        [ class "tc center pointer"
        , style
            [ widthStyle 50
            , color worldData.textColor
            ]
        ]
        [ renderIcon worldData.seedType
        , p [] [ text <| toString number ]
        ]


renderIcon : SeedType -> Html msg
renderIcon seedType =
    case seedType of
        Sunflower ->
            sunflower

        Foxglove ->
            foxglove

        Lupin ->
            lupin

        Rose ->
            rose

        Marigold ->
            marigold
