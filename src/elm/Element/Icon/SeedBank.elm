module Element.Icon.SeedBank exposing (icon)

import Css.Style as Style exposing (svgStyle)
import Css.Transform exposing (translateY)
import Css.Transition exposing (transitionAll)
import Seed exposing (Seed)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import View.Seed as Seed
import View.Seed.Mono exposing (greyedOutSeed)



-- Seed Bank


icon : Seed -> Float -> Svg msg
icon seed percentFull =
    Svg.svg
        [ viewBox "0 0 124.5 193.5"
        , width "100%"
        , height "100%"
        ]
        [ Svg.defs []
            [ Svg.rect
                [ height (String.fromFloat fullHeight)
                , id (fillLevelId seed)
                , width "100%"
                ]
                []
            ]
        , Svg.g []
            [ greyedOutSeed
            , Svg.g []
                [ Svg.mask
                    [ fill "white"
                    , id (seedBankId seed)
                    ]
                    [ Svg.use
                        [ xlinkHref ("#" ++ fillLevelId seed)
                        , offsetLevelStyles percentFull
                        ]
                        []
                    ]
                , Svg.g
                    [ mask ("url(#" ++ seedBankId seed ++ ")") ]
                    [ Seed.view seed ]
                ]
            ]
        ]


seedBankId : Seed -> String
seedBankId seed =
    "seed-bank-" ++ seedId seed


fillLevelId : Seed -> String
fillLevelId seed =
    "fill-level-" ++ seedId seed


seedId : Seed -> String
seedId =
    Seed.name >> String.toLower


fullHeight : Float
fullHeight =
    193.5


offsetLevelStyles : Float -> Svg.Attribute msg
offsetLevelStyles percentFull =
    svgStyle
        [ transitionAll 1500 []
        , Style.transform [ translateY (offset percentFull) ]
        ]


offset : Float -> Float
offset percentFull =
    (fullHeight / 100) * (100 - percentFull)
