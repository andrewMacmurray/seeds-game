module View.Icon.SeedBank exposing (seedBank)

import Css.Style as Style exposing (svgStyle)
import Css.Transform exposing (translateY)
import Css.Transition exposing (transitionAll)
import Html exposing (Html)
import Seed exposing (Seed)
import Svg
import Svg.Attributes exposing (..)
import View.Seed as Seed
import View.Seed.Mono exposing (greyedOutSeed)


seedBank : Seed -> Float -> Html msg
seedBank seed percentFull =
    let
        fullHeight =
            193.5

        seedLevelOffset =
            (fullHeight / 100) * (100 - percentFull)

        stringSeedType =
            seed |> Seed.name |> String.toLower

        seedBankId =
            "seed-bank-" ++ stringSeedType

        fillLevelId =
            "fill-level-" ++ stringSeedType

        offsetLevelStyles =
            svgStyle
                [ transitionAll 1500 []
                , Style.transform [ translateY seedLevelOffset ]
                ]
    in
    Svg.svg
        [ viewBox "0 0 124.5 193.5"
        , width "100%"
        , height "100%"
        ]
        [ Svg.defs []
            [ Svg.rect
                [ height <| String.fromFloat fullHeight
                , id <| fillLevelId
                , width "100%"
                ]
                []
            ]
        , Svg.g []
            [ greyedOutSeed
            , Svg.g []
                [ Svg.mask
                    [ fill "white"
                    , id seedBankId
                    ]
                    [ Svg.use
                        [ xlinkHref <| "#" ++ fillLevelId
                        , offsetLevelStyles
                        ]
                        []
                    ]
                , Svg.g
                    [ mask <| "url(#" ++ seedBankId ++ ")" ]
                    [ Seed.view seed ]
                ]
            ]
        ]
