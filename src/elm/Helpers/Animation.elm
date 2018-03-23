module Helpers.Animation exposing (..)

import Formatting exposing ((<>), print)
import Helpers.Css.Format exposing (transformInline_, scale_, opacity_, translateY_)
import Helpers.Css.Style exposing (keyframesAnimation, step)
import Html exposing (Html, node)
import Html.Attributes exposing (property)
import Json.Encode as Encode


type alias KeyframesAnimation a =
    { name : String
    , frames : List a
    }


embeddedAnimations : String -> Html msg
embeddedAnimations animations =
    node "style" [ property "textContent" <| encodedAnimations animations ] []


encodedAnimations : String -> Encode.Value
encodedAnimations animations =
    [ internalAnimations
    , animations
    ]
        |> String.join " "
        |> Encode.string


internalAnimations : String
internalAnimations =
    String.join " "
        [ bulge
        , bulgeFade
        , exitDown
        ]


exitDown : String
exitDown =
    map3 stepTranslateYFade
        { name = "exit-down"
        , frames =
            [ ( 0, 0, 1 )
            , ( 100, 300, 0 )
            ]
        }


bulgeFade : String
bulgeFade =
    map3 stepScaleFade
        { name = "bulge-fade"
        , frames =
            [ ( 0, 1, 1 )
            , ( 100, 2.5, 0 )
            ]
        }


bulge : String
bulge =
    map2 stepScale
        { name = "bulge"
        , frames =
            [ ( 0, 0.5 )
            , ( 50, 1.3 )
            , ( 100, 1 )
            ]
        }


map2 : (a -> b -> String) -> KeyframesAnimation ( a, b ) -> String
map2 f { frames, name } =
    frames
        |> List.map (uncurry f)
        |> keyframesAnimation name


map3 : (a -> b -> c -> String) -> KeyframesAnimation ( a, b, c ) -> String
map3 f { frames, name } =
    frames
        |> List.map (\( a, b, c ) -> f a b c)
        |> keyframesAnimation name


stepTranslateYFade : Int -> number -> number -> String
stepTranslateYFade =
    step <| (transformInline_ translateY_) <> opacity_


stepScaleFade : Int -> number -> number -> String
stepScaleFade =
    step <| (transformInline_ scale_) <> opacity_


stepScale : Int -> number -> String
stepScale =
    step <| transformInline_ scale_
