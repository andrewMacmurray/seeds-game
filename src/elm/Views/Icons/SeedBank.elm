module Views.Icons.SeedBank exposing (seedBank)

import Data.Board.Types exposing (..)
import Css.Style as Style exposing (svgStyles)
import Css.Transform as Css exposing (translateY)
import Css.Transition exposing (easeAll)
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
            seedType |> Debug.toString |> String.toLower

        seedBankId =
            "seed-bank-" ++ stringSeedType

        seedLevelId =
            "seed-level-" ++ stringSeedType

        offsetLevelStyles =
            svgStyles
                [ easeAll 1500
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
                , id <| seedLevelId
                , width "100%"
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
                    [ Svg.use
                        [ xlinkHref <| "#" ++ seedLevelId
                        , offsetLevelStyles
                        ]
                        []
                    ]
                , Svg.g
                    [ mask <| "url(#" ++ seedBankId ++ ")" ]
                    [ renderSeed seedType ]
                ]
            ]
        ]
