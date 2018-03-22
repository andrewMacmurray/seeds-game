module Scenes.Summary.View exposing (..)

import Config.Color exposing (washedYellow)
import Config.Levels exposing (allLevels)
import Data.Board.Types exposing (..)
import Data.Level.Summary exposing (..)
import Data.Level.Types exposing (Progress)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types exposing (..)
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank)


summaryView : Model -> Html Msg
summaryView ({ progress, currentLevel } as model) =
    let
        primarySeed =
            primarySeedType allLevels progress currentLevel |> Maybe.withDefault Sunflower

        resources =
            secondaryResourceTypes allLevels currentLevel |> Maybe.withDefault []
    in
        div
            [ class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
            , style
                [ heightStyle model.window.height
                , background washedYellow
                , animationStyle "fade-in 1s linear"
                ]
            ]
            [ div [ style [ ( "margin-top", pc -3 ) ] ]
                [ div
                    [ style [ widthStyle 65, marginBottom 45 ]
                    , class "center"
                    ]
                    [ seedBank primarySeed <| percentComplete allLevels (Seed primarySeed) progress currentLevel ]
                , div [ style [ heightStyle 107 ] ] <| List.map (renderResourceBank progress currentLevel) resources
                ]
            ]


renderResourceBank : Progress -> Maybe Progress -> TileType -> Html msg
renderResourceBank progress currentLevel tileType =
    case tileType of
        Rain ->
            div [ style [ widthStyle 40 ], class "dib ph1 mh4" ]
                [ rainBank <| percentComplete allLevels Rain progress currentLevel
                ]

        Sun ->
            div [ style [ widthStyle 40 ], class "dib mh4" ]
                [ sunBank <| percentComplete allLevels Sun progress currentLevel
                ]

        Seed seedType ->
            div [ style [ widthStyle 40 ], class "dib ph1 mh4" ]
                [ seedBank seedType <| percentComplete allLevels (Seed seedType) progress currentLevel
                ]

        _ ->
            span [] []
