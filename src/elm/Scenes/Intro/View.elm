module Scenes.Intro.View exposing (..)

import Config.Color as Color
import Helpers.Css.Style exposing (Style, background, color, marginTop, widthStyle)
import Helpers.Css.Transition exposing (easeAll)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Scenes.Intro.Types exposing (..)
import Views.Intro.BloomingFlowers exposing (bloomingFlowers)
import Views.Intro.DyingLandscape exposing (dyingLandscape)
import Views.Intro.GrowingSeeds exposing (growingSeeds)
import Window


introView : IntroModel -> Html IntroMsg
introView model =
    div
        [ class "fixed top-0 left-0 w-100 h-100 z-1"
        , handleClick model.scene
        , style
            [ background model.backdrop
            , easeAll 1000
            ]
        ]
        [ p
            [ class "tc f3 relative z-3"
            , style
                [ textOffset model.window
                , color model.textColor
                , easeAll 1000
                ]
            , classList
                [ ( "o-0", not model.textVisible )
                , ( "o-100", model.textVisible )
                ]
            ]
            [ text model.text ]
        , renderScene model
        ]


renderScene : IntroModel -> Html IntroMsg
renderScene model =
    case model.scene of
        DyingLandscape environment vis ->
            dyingLandscape environment vis

        GrowingSeeds vis ->
            growingSeeds model.window vis

        BloomingFlowers vis ->
            bloomingFlowers vis


textOffset : Window.Size -> Style
textOffset window =
    marginTop <| (window.height // 2) - 120


handleClick : Scene -> Attribute IntroMsg
handleClick scene =
    case scene of
        DyingLandscape Alive _ ->
            onClick TransitionToDead

        _ ->
            onClick Reset
