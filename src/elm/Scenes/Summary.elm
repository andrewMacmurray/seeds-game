module Scenes.Summary exposing (..)

import Config.Color exposing (gold, rainBlue, washedYellow)
import Config.Levels exposing (allLevels)
import Data.Board.Types exposing (..)
import Data.Level.Summary exposing (..)
import Data.Level.Types exposing (Progress)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform exposing (transformStyle, translateX)
import Helpers.Wave exposing (wave)
import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
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
                , animationStyle
                    { name = "fade-in"
                    , duration = 1000
                    , timing = Linear
                    }
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
                [ renderResourceFill tileType
                , rainBank <| percentComplete allLevels Rain progress currentLevel
                ]

        Sun ->
            div [ style [ widthStyle 40 ], class "dib mh4" ]
                [ renderResourceFill tileType
                , sunBank <| percentComplete allLevels Sun progress currentLevel
                ]

        Seed seedType ->
            div [ style [ widthStyle 40 ], class "dib ph1 mh4" ]
                [ seedBank seedType <| percentComplete allLevels (Seed seedType) progress currentLevel
                ]

        _ ->
            span [] []


renderResourceFill : TileType -> Html msg
renderResourceFill tileType =
    case tileType of
        Rain ->
            div [ style [ heightStyle 100 ] ]
                [ div [ style [ widthStyle 15 ], class "center" ] [ rainBank 100 ]
                , div [ class "relative" ] <| List.map (drop rainBlue) <| List.range 1 50
                ]

        Sun ->
            div [ style [ heightStyle 100 ] ]
                [ div [ style [ widthStyle 22 ], class "center" ] [ sunBank 100 ]
                , div [ class "relative" ] <| List.map (drop gold) <| List.range 4 54
                ]

        _ ->
            span [] []


drop : String -> Int -> Html msg
drop bgColor n =
    let
        d =
            if n % 3 == 0 then
                30
            else if n % 3 == 1 then
                60
            else
                90
    in
        div
            [ style
                [ transformStyle
                    [ translateX <|
                        wave
                            { left = -5
                            , center = 0
                            , right = 5
                            }
                            (n - 1)
                    ]
                ]
            ]
            [ div
                [ class "br-100 absolute left-0 right-0 center"
                , style
                    [ widthStyle 10
                    , heightStyle 10
                    , background bgColor
                    , opacityStyle 0
                    , animationWithOptionsStyle
                        { name = "fade-slide-down"
                        , duration = 200
                        , delay = Just <| toFloat <| n * d
                        , timing = Linear
                        , iteration = Nothing
                        , fill = Forwards
                        }
                    ]
                ]
                []
            ]
