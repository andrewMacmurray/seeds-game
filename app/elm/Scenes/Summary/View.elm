module Scenes.Summary.View exposing (..)

import Data.Color exposing (washedYellow)
import Data.Level.Summary exposing (..)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (SeedType(..), TileType(..))
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank)


summaryView : Model -> Html Msg
summaryView ({ progress, currentLevel } as model) =
    let
        seedType =
            primarySeedType progress currentLevel |> Maybe.withDefault Sunflower
    in
        div
            [ class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
            , style
                [ heightStyle model.window.height
                , background washedYellow
                , animationStyle "fade-in 1s linear"
                ]
            ]
            [ div [ style [ heightStyle 107, ( "margin-top", pc -7 ) ] ]
                [ div
                    [ class "dib mh4"
                    , style [ widthStyle 40 ]
                    ]
                    [ rainBank <| percentComplete Rain progress currentLevel ]
                , div
                    [ class "dib mh4"
                    , style [ widthStyle 70 ]
                    ]
                    [ seedBank seedType <| percentComplete (Seed seedType) progress currentLevel ]
                , div
                    [ class "dib mh4"
                    , style [ widthStyle 50 ]
                    ]
                    [ sunBank <| percentComplete Sun progress currentLevel ]
                ]
            ]
