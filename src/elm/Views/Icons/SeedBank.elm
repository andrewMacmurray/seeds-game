module Views.Icons.SeedBank exposing (seedBank)

import Css.Style as Style exposing (svgStyle)
import Css.Transform exposing (translateY)
import Css.Transition exposing (transitionAll)
import Data.Board.Tile as Tile
import Html exposing (Html)
import Svg
import Svg.Attributes exposing (..)
import Views.Seed.All exposing (renderSeed)
import Views.Seed.Mono exposing (greyedOutSeed)


seedBank : Tile.SeedType -> Float -> Html msg
seedBank seedType percentFull =
    let
        fullHeight =
            193.5

        seedLevelOffset =
            (fullHeight / 100) * (100 - percentFull)

        stringSeedType =
            seedType |> Tile.seedName |> String.toLower

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
                    [ renderSeed seedType ]
                ]
            ]
        ]
