module Scenes.Hub.View exposing (..)

import Dict
import Helpers.Style exposing (backgroundColor, color, heightStyle, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model exposing (..)
import Scenes.Level.Model exposing (SeedType(..))
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


hub : Model -> Html Msg
hub model =
    div
        [ class "w-100 fixed overflow-y-scroll z-5"
        , id "hub"
        , style [ heightStyle model.window.height ]
        ]
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
renderLevel worldData ( number, level ) =
    div
        [ onClick <| StartLevel level
        , class "tc center pointer"
        , style
            [ widthStyle 40
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
