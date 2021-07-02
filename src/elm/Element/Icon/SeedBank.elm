module Element.Icon.SeedBank exposing (full, icon)

import Css.Style as Style
import Css.Transition as Transition
import Element exposing (Element)
import Element.Icon as Icon
import Element.Seed as Seed
import Seed exposing (Seed)
import Simple.Animation as Animation
import Svg exposing (Attribute)
import Svg.Attributes exposing (..)
import Utils.Svg as Svg
import Utils.Transform exposing (translateY)



-- Seed Bank


type alias Options =
    { seed : Seed
    , percent : Float
    , delay : Animation.Millis
    }


icon : Options -> Element msg
icon options =
    Icon.el
        [ Svg.viewBox_ 0 0 124.5 193.5
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
        , Seed.grey_
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
            [ Seed.svg options.seed ]
        ]


full : Seed -> Element msg
full seed =
    Icon.el
        [ viewBox "0 0 124.5 193.5"
        , width "100%"
        , height "100%"
        ]
        [ Seed.svg seed
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
