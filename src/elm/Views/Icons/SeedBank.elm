module Views.Icons.SeedBank exposing (..)

import Data.Board.Types exposing (..)
import Helpers.Css.Style exposing (pc, svgTranslate)
import Html exposing (Html)
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

        stringSeedType =
            seedType |> toString |> String.toLower

        seedBankId =
            "seed-bank-" ++ stringSeedType

        seedLevelId =
            "seed-level-" ++ stringSeedType
    in
        Svg.svg
            [ viewBox "0 0 124.5 193.5"
            , width "100%"
            , height "100%"
            ]
            [ Svg.defs []
                [ Svg.rect
                    [ height <| toString fullHeight
                    , id <| seedLevelId
                    , width "100%"
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
                        , id seedBankId
                        ]
                        [ Svg.use [ xlinkHref <| "#" ++ seedLevelId ] [] ]
                    , Svg.g
                        [ mask <| "url(#" ++ seedBankId ++ ")" ]
                        [ renderSeed seedType ]
                    ]
                ]
            ]
