module Scenes.Summary exposing (drop, renderResourceBank, renderResourceFill, seedDrop, summaryView)

import Config.Color exposing (gold, rainBlue, washedYellow)
import Config.Levels exposing (allLevels)
import Data.Board.Types exposing (..)
import Data.Level.Summary exposing (..)
import Data.Level.Types exposing (Progress)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform exposing (translateX, translateY)
import Helpers.Wave exposing (wave)
import Html exposing (..)
import Html.Attributes exposing (class)
import Types exposing (..)
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank, sunBankFull)
import Views.Seed.All exposing (renderSeed)


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
        , styleAttr (heightStyle <| toFloat model.window.height)
        , styleAttr (background washedYellow)
        , styleAttr
            (animationStyle
                { name = "fade-in"
                , duration = 1000
                , timing = Linear
                }
            )
        ]
        [ div [ styleAttr (marginTop -100) ]
            [ div
                [ styleAttr (width 65)
                , styleAttr (marginBottom 30)
                , class "center"
                ]
                [ seedBank primarySeed <| percentComplete allLevels (Seed primarySeed) progress currentLevel ]
            , div [ styleAttr (heightStyle 50) ] <| List.map (renderResourceBank progress currentLevel) resources
            ]
        ]


renderResourceBank : Progress -> Maybe Progress -> TileType -> Html msg
renderResourceBank progress currentLevel tileType =
    let
        fillLevel =
            percentComplete allLevels tileType progress currentLevel
    in
    case tileType of
        Rain ->
            div [ styleAttr (width 40), class "dib ph1 mh4" ]
                [ renderResourceFill tileType
                , rainBank fillLevel
                ]

        Sun ->
            div [ styleAttr (width 40), class "dib mh4" ]
                [ renderResourceFill tileType
                , sunBank fillLevel
                ]

        Seed seedType ->
            div [ styleAttr (width 40), class "dib ph1 mh4" ]
                [ renderResourceFill tileType
                , seedBank seedType fillLevel
                ]

        _ ->
            span [] []


renderResourceFill : TileType -> Html msg
renderResourceFill tileType =
    case tileType of
        Rain ->
            div [ styleAttr (heightStyle 50) ]
                [ div [ styleAttr (width 13), class "center" ] [ rainBankFull ]
                , div [ class "relative" ] <| List.map (drop rainBlue) <| List.range 1 50
                ]

        Sun ->
            div [ styleAttr (heightStyle 50) ]
                [ div [ styleAttr (width 18), class "center" ] [ sunBankFull ]
                , div [ class "relative" ] <| List.map (drop gold) <| List.range 4 54
                ]

        Seed seedType ->
            div [ styleAttr (heightStyle 50) ]
                [ div [ styleAttr (width 15), class "center" ] [ renderSeed seedType ]
                , div [ class "relative", styleAttr (transform [ translateY -10 ]) ] <| List.map (seedDrop seedType) <| List.range 7 57
                ]

        _ ->
            span [] []


seedDrop : SeedType -> Int -> Html msg
seedDrop seedType n =
    let
        d =
            if modBy 3 n == 0 then
                30

            else if modBy 3 n == 1 then
                60

            else
                90
    in
    div
        [ styleAttr
            (transform
                [ translateX <|
                    wave
                        { left = -5
                        , center = 0
                        , right = 5
                        }
                        (n - 1)
                ]
            )
        ]
        [ div
            [ class "absolute top-0 left-0 right-0 center"
            , styleAttr (width 5)
            , styleAttr (heightStyle 8)
            , styleAttr (opacityStyle 0)
            , styleAttr
                (animationWithOptionsStyle
                    { name = "fade-slide-down"
                    , duration = 150
                    , delay = Just <| toFloat <| n * d
                    , timing = Linear
                    , iteration = Nothing
                    , fill = Forwards
                    }
                )
            ]
            [ renderSeed seedType ]
        ]


drop : String -> Int -> Html msg
drop bgColor n =
    let
        d =
            if modBy 3 n == 0 then
                30

            else if modBy 3 n == 1 then
                60

            else
                90
    in
    div
        [ styleAttr
            (transform
                [ translateX <|
                    wave
                        { left = -5
                        , center = 0
                        , right = 5
                        }
                        (n - 1)
                ]
            )
        ]
        [ div
            [ class "br-100 absolute left-0 right-0 center"
            , styleAttr (width 6)
            , styleAttr (heightStyle 6)
            , styleAttr (background bgColor)
            , styleAttr (opacityStyle 0)
            , styleAttr
                (animationWithOptionsStyle
                    { name = "fade-slide-down"
                    , duration = 150
                    , delay = Just <| toFloat <| n * d
                    , timing = Linear
                    , iteration = Nothing
                    , fill = Forwards
                    }
                )
            ]
            []
        ]
