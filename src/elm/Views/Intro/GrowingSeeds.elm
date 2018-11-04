module Views.Intro.GrowingSeeds exposing
    ( growingSeed
    , growingSeeds
    , mainSeedStyles
    , seedsLeft
    , seedsRight
    , sideSeedsContainer
    )

import Config.Scale exposing (ScreenSize(..), screenSize, tileScaleFactor)
import Css.Animation exposing (animation, delay, ease, easeOut)
import Css.Style exposing (Style, empty, marginLeft, marginRight, opacity, style, styles, transform, transformOrigin, width)
import Css.Transform as Transform
import Css.Transition as Transition exposing (transition)
import Data.Board.Types exposing (SeedType(..))
import Data.Visibility exposing (..)
import Helpers.Attribute as Attribute
import Html exposing (..)
import Html.Attributes exposing (class)
import Shared exposing (Window)
import Views.Seed.All exposing (renderSeed)


growingSeeds : Window -> Visibility -> Html msg
growingSeeds window vis =
    let
        size =
            screenSize window
    in
    div [ class "flex justify-center" ] <|
        [ sideSeedsContainer vis <| List.reverse <| List.map (growingSeed window) (seedsLeft size)
        , div [ mainSeedStyles vis ] [ growingSeed window ( 0, Sunflower, 1.1 ) ]
        , sideSeedsContainer vis <| List.map (growingSeed window) (seedsRight size)
        ]


mainSeedStyles : Visibility -> Attribute msg
mainSeedStyles vis =
    case vis of
        Leaving ->
            style
                [ animation "slide-down-scale-out" 2000 [ delay 500, ease ]
                , transformOrigin "bottom"
                ]

        _ ->
            Attribute.empty


sideSeedsContainer : Visibility -> List (Html msg) -> Html msg
sideSeedsContainer vis =
    case vis of
        Leaving ->
            div [ class "o-0 flex justify-center", style [ transition "opacity" 1500 [] ] ]

        Entering ->
            div [ class "o-100 flex justify-center", style [ transition "opacity" 1500 [] ] ]

        Visible ->
            div [ class "o-100 flex justify-center" ]

        Hidden ->
            div [ class "o-0 flex justify-center" ]


growingSeed : Window -> ( Int, SeedType, Float ) -> Html msg
growingSeed window ( index, seedType, scale ) =
    let
        delayMs =
            index * 100
    in
    div [ class "flex items-end" ]
        [ div
            [ style
                [ width <| 50 * scale * tileScaleFactor window
                , marginLeft 5
                , marginRight 5
                , transform [ Transform.scale 0 ]
                , transformOrigin "center"
                , animation "bulge-elastic" 500 [ easeOut, delay delayMs ]
                ]
            , class "growing-seed"
            ]
            [ renderSeed seedType ]
        ]


seedsLeft : ScreenSize -> List ( Int, SeedType, Float )
seedsLeft screenSize =
    case screenSize of
        Small ->
            [ ( 3, Marigold, 0.7 )
            , ( 1, Foxglove, 0.5 )
            , ( 5, Rose, 0.8 )
            , ( 10, Lupin, 0.5 )
            ]

        _ ->
            [ ( 3, Marigold, 0.7 )
            , ( 9, Foxglove, 0.5 )
            , ( 7, Rose, 0.8 )
            , ( 1, Lupin, 1 )
            , ( 5, Marigold, 0.6 )
            ]


seedsRight : ScreenSize -> List ( Int, SeedType, Float )
seedsRight screenSize =
    case screenSize of
        Small ->
            [ ( 2, Foxglove, 0.6 )
            , ( 3, Marigold, 0.7 )
            , ( 9, Sunflower, 0.5 )
            , ( 6, Lupin, 0.5 )
            ]

        _ ->
            [ ( 10, Foxglove, 0.6 )
            , ( 2, Marigold, 0.7 )
            , ( 8, Sunflower, 0.5 )
            , ( 6, Rose, 1 )
            , ( 4, Lupin, 0.8 )
            ]
