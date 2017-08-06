module Helpers.Animation exposing (..)

import Formatting exposing ((<>), print)
import Helpers.Style exposing (keyframesAnimation, opacity_, scale_, step, step_, transform_, translateY_)
import Html exposing (Html, node)
import Html.Attributes exposing (property)
import Json.Encode as Encode
import Model exposing (Model)


embeddedAnimations : Model -> Html msg
embeddedAnimations model =
    node "style" [ property "textContent" <| encodedAnimations model ] []


encodedAnimations : Model -> Encode.Value
encodedAnimations model =
    [ internalAnimations
    , model.externalAnimations
    ]
        |> String.join " "
        |> Encode.string


internalAnimations : String
internalAnimations =
    [ bulge
    , bulgeFade
    , exitDown
    ]
        |> String.join " "


exitDown : String
exitDown =
    [ ( 0, 0, 1 )
    , ( 100, 300, 0 )
    ]
        |> List.map (\( step, y, opacity ) -> stepTranslateYFade step y opacity)
        |> keyframesAnimation "exit-down"


bulgeFade : String
bulgeFade =
    [ ( 0, 1, 1 )
    , ( 100, 2.5, 0 )
    ]
        |> List.map (\( step, scale, opacity ) -> stepScaleFade step scale opacity)
        |> keyframesAnimation "bulge-fade"


bulge : String
bulge =
    [ ( 0, 0.5 )
    , ( 50, 1.3 )
    , ( 100, 1 )
    ]
        |> List.map (uncurry stepScale)
        |> keyframesAnimation "bulge"


stepTranslateYFade : Int -> number -> number -> String
stepTranslateYFade =
    step <| (transform_ translateY_) <> opacity_


stepScaleFade : Int -> number -> number -> String
stepScaleFade =
    step <| (transform_ scale_) <> opacity_


stepScale : Int -> number -> String
stepScale =
    step <| transform_ scale_
