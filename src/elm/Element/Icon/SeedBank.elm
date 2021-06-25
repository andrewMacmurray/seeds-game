module Element.Icon.SeedBank exposing (full, icon)

import Css.Style as Style
import Css.Transform exposing (translateY)
import Css.Transition as Transition
import Element exposing (Element)
import Element.Icon as Icon
import Seed exposing (Seed)
import Simple.Animation as Animation
import Svg exposing (Attribute)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg
import View.Seed as Seed
import View.Seed.Mono exposing (greyedOutSeed)



-- Seed Bank


type alias Options =
    { seed : Seed
    , percent : Float
    , delay : Animation.Millis
    }


icon : Options -> Element msg
icon options =
    Icon.view
        [ viewBox "0 0 124.5 193.5"
        , width "100%"
        , height "100%"
        ]
        [ Svg.defs []
            [ Svg.rect
                [ height (String.fromFloat fullHeight)
                , id (fillLevelId options.seed)
                , width "100%"
                , height "100%"
                ]
                []
            ]
        , greyedOutSeed
        , Svg.mask
            [ fill "white"
            , id (seedBankId options.seed)
            ]
            [ Svg.use
                [ xlinkHref ("#" ++ fillLevelId options.seed)
                , offsetLevelStyles options
                ]
                []
            ]
        , Svg.g_
            [ mask ("url(#" ++ seedBankId options.seed ++ ")") ]
            [ Seed.view options.seed ]
        ]


full : Seed -> Element msg
full seed =
    Icon.view
        [ viewBox "0 0 124.5 193.5"
        , width "100%"
        , height "100%"
        ]
        [ Seed.view seed
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


offsetLevelStyles : Options -> Attribute msg
offsetLevelStyles options =
    Style.svg
        [ Style.transform [ translateY (offset options.percent) ]
        , Transition.transition "transform" 1500 [ Transition.delay options.delay ]
        ]


offset : Float -> Float
offset percentFull =
    (fullHeight / 100) * (100 - percentFull)
