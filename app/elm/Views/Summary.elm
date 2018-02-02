module Views.Summary exposing (..)

import Data.Color exposing (washedYellow)
import Data.Level.Summary exposing (currentTotalScoresForWorld, percentComplete, totalTargetScoresForWorld)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types exposing (SeedType(..), TileType(..))
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank)


summaryView : Model -> Html Msg
summaryView ({ progress } as model) =
    div
        [ class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        , style
            [ heightStyle model.window.height
            , background washedYellow
            , animationStyle "fade-in 1.5s linear"
            ]
        ]
        [ div [ style [ heightStyle 107, ( "margin-top", pc -7 ) ] ]
            [ div
                [ class "dib mh4"
                , style [ widthStyle 40 ]
                ]
                [ rainBank <| percentComplete Rain progress ]
            , div
                [ class "dib mh4"
                , style [ widthStyle 70 ]
                ]
                [ seedBank Sunflower <| percentComplete (Seed Sunflower) progress ]
            , div
                [ class "dib mh4"
                , style [ widthStyle 50 ]
                ]
                [ sunBank <| percentComplete Sun progress ]
            ]
        ]
