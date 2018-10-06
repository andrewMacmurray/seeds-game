module Scenes.Title exposing
    ( TitleModel
    , fade
    , fadeInStyles
    , fadeOutStyles
    , fadeSeeds
    , handleStart
    , percentWindowHeight
    , seedEntranceDelays
    , seedExitDelays
    , seeds
    , titleView
    )

import Config.Scale as ScaleConfig
import Css.Animation exposing (animation, delay, linear)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Timing exposing (..)
import Data.Level.Types exposing (Progress)
import Data.Visibility exposing (..)
import Data.Window as Window
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Types exposing (Msg(..))
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)



-- Model


type alias TitleModel model =
    { model
        | window : Window.Size
        , titleAnimation : Visibility
        , progress : Progress
    }



-- View


titleView : TitleModel model -> Html Msg
titleView { window, titleAnimation, progress } =
    div
        [ class "absolute left-0 right-0 z-5 tc"
        , style [ bottom <| toFloat window.height / 2.4 ]
        ]
        [ div [] [ seeds titleAnimation ]
        , p
            [ styles
                [ [ color darkYellow, marginTop 45 ]
                , fadeInStyles titleAnimation 1500 500
                , fadeOutStyles titleAnimation 1000 500
                ]
            , class "f3 tracked-mega"
            ]
            [ text "seeds" ]
        , button
            [ styles
                [ [ borderNone
                  , marginTop 15
                  , color white
                  , backgroundColor lightOrange
                  ]
                , fadeInStyles titleAnimation 800 2500
                , fadeOutStyles titleAnimation 1000 0
                ]
            , class "outline-0 br4 pv2 ph3 f5 pointer sans-serif tracked-mega"
            , handleStart progress
            ]
            [ text "PLAY" ]
        ]


handleStart : Progress -> Attribute Msg
handleStart progress =
    if progress == ( 1, 1 ) then
        onClick GoToIntro

    else
        onClick GoToHub


percentWindowHeight : Float -> Window.Size -> Float
percentWindowHeight percent window =
    toFloat window.height / 100 * percent


seeds : Visibility -> Html msg
seeds vis =
    div
        [ style
            [ maxWidth 450
            , paddingLeft ScaleConfig.windowPadding
            , paddingRight ScaleConfig.windowPadding
            ]
        , class "flex center"
        ]
        (List.map3 (fadeSeeds vis)
            (seedEntranceDelays 500)
            (seedExitDelays 500)
            [ foxglove
            , marigold
            , sunflower
            , lupin
            , rose
            ]
        )


seedEntranceDelays : Int -> List Int
seedEntranceDelays interval =
    [ 3, 2, 1, 2, 3 ] |> List.map ((*) interval)


seedExitDelays : Int -> List Int
seedExitDelays interval =
    [ 0, 1, 2, 1, 0 ] |> List.map ((*) interval)


fadeSeeds : Visibility -> Int -> Int -> Html msg -> Html msg
fadeSeeds vis entranceDelay exitDelay seed =
    div
        [ styles
            [ fadeInStyles vis 1000 entranceDelay
            , fadeOutStyles vis 1000 exitDelay
            ]
        , class "mh2"
        ]
        [ seed ]


fadeOutStyles : Visibility -> Int -> Int -> List Style
fadeOutStyles vis duration delay =
    case vis of
        Leaving ->
            [ fade vis duration delay
            , opacity 1
            ]

        _ ->
            []


fadeInStyles : Visibility -> Int -> Int -> List Style
fadeInStyles vis duration delay =
    case vis of
        Entering ->
            [ fade vis duration delay
            , opacity 0
            ]

        _ ->
            []


fade : Visibility -> Int -> Int -> Style
fade vis duration delayMs =
    let
        fadeDirection name =
            animation name duration [ delay delayMs, linear ]
    in
    case vis of
        Entering ->
            fadeDirection "fade-in"

        Leaving ->
            fadeDirection "fade-out"

        _ ->
            Style.empty
