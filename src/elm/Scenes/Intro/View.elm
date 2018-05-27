module Scenes.Intro.View exposing (..)

import Helpers.Css.Style exposing (Style, background, color, marginTop, widthStyle)
import Helpers.Css.Transition exposing (easeAll)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Intro.Types exposing (..)
import Views.Intro.DyingLandscape exposing (dyingLandscape)
import Views.Intro.GrowingSeeds exposing (growingSeeds)
import Views.Intro.RollingHills exposing (rollingHills)
import Window


introView : IntroModel -> Html IntroMsg
introView model =
    div
        [ class "fixed top-0 left-0 w-100 h-100 z-1"
        , style
            [ background model.backdrop
            , easeAll 1500
            ]
        ]
        [ p
            [ class "tc f5 f3-ns relative z-2"
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

        RollingHills vis ->
            rollingHills vis


textOffset : Window.Size -> Style
textOffset window =
    marginTop <| (window.height // 2) - 120
