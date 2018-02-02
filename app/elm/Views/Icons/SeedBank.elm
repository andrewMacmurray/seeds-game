module Views.Icons.SeedBank exposing (..)

import Helpers.Style exposing (svgTranslate)
import Html exposing (Html)
import Scenes.Level.Types exposing (SeedType(..))
import Svg
import Svg.Attributes exposing (..)
import Views.Seed.All exposing (renderSeed)


seedBank : SeedType -> Float -> Html msg
seedBank seedType percentFull =
    let
        fullHeight =
            193.5

        seedLevelOffset =
            (fullHeight / 100) * (100 - percentFull)
    in
        Svg.svg [ viewBox "0 0 124.5 193.5" ]
            [ Svg.defs []
                [ Svg.rect
                    [ height <| toString fullHeight
                    , id "seed-level"
                    , width "124.5"
                    , style "transition: transform 1.5s ease"
                    , transform <| svgTranslate 0 seedLevelOffset
                    ]
                    []
                ]
            , Svg.g []
                [ renderSeed GreyedOut
                , Svg.g []
                    [ Svg.mask
                        [ fill "white"
                        , id "seed-bank"
                        ]
                        [ Svg.use [ xlinkHref "#seed-level" ] [] ]
                    , Svg.g
                        [ mask "url(#seed-bank)" ]
                        [ renderSeed seedType ]
                    ]
                ]
            ]
