module Views.Intro.GrowingSeeds exposing
    ( growingSeed
    , growingSeeds
    , mainSeedStyles
    , seedsLeft
    , seedsRight
    , sideSeedsContainer
    )

import Config.Scale exposing (tileScaleFactor)
import Data.Board.Types exposing (SeedType(..))
import Data.Visibility exposing (..)
import Data.Window as Window
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style exposing (Style, empty, marginLeft, marginRight, opacity, style, transform, transformOrigin, width)
import Helpers.Css.Timing exposing (TimingFunction(..))
import Helpers.Css.Transform as Transform
import Helpers.Css.Transition exposing (ease)
import Helpers.Html exposing (emptyProperty)
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.Seed.All exposing (renderSeed)


growingSeeds : Window.Size -> Visibility -> Html msg
growingSeeds window vis =
    div [ class "flex justify-center" ] <|
        [ sideSeedsContainer vis <| List.reverse <| List.map (growingSeed window) seedsLeft
        , div [ mainSeedStyles vis ] [ growingSeed window ( 0, Sunflower, 1.1 ) ]
        , sideSeedsContainer vis <| List.map (growingSeed window) seedsRight
        ]


mainSeedStyles : Visibility -> Attribute msg
mainSeedStyles vis =
    case vis of
        Leaving ->
            style
                [ animationWithOptionsStyle
                    { name = "slide-down-scale-out"
                    , duration = 2000
                    , delay = Just 500
                    , timing = Ease
                    , fill = Forwards
                    , iteration = Nothing
                    }
                ]

        _ ->
            emptyProperty


sideSeedsContainer : Visibility -> List (Html msg) -> Html msg
sideSeedsContainer vis =
    case vis of
        Leaving ->
            div [ class "o-0 flex justify-center", style [ ease "opacity" 1500 ] ]

        Entering ->
            div [ class "o-100 flex justify-center", style [ ease "opacity" 1500 ] ]

        Visible ->
            div [ class "o-100 flex justify-center" ]

        Hidden ->
            div [ class "o-0 flex justify-center" ]


growingSeed : Window.Size -> ( Int, SeedType, Float ) -> Html msg
growingSeed window ( index, seedType, scale ) =
    let
        delay =
            toFloat <| index * 100
    in
    div [ class "flex items-end" ]
        [ div
            [ style
                [ width <| 50 * scale * tileScaleFactor window
                , marginLeft 5
                , marginRight 5
                , transform [ Transform.scale 0 ]
                , transformOrigin "center"
                , animationWithOptionsStyle
                    { name = "bulge-elastic"
                    , duration = 500
                    , timing = EaseOut
                    , delay = Just delay
                    , iteration = Nothing
                    , fill = Forwards
                    }
                ]
            , class "growing-seed"
            ]
            [ renderSeed seedType ]
        ]


seedsLeft : List ( Int, SeedType, Float )
seedsLeft =
    [ ( 3, Marigold, 0.7 )
    , ( 9, Foxglove, 0.5 )
    , ( 7, Rose, 0.8 )
    , ( 1, Lupin, 1 )
    , ( 5, Marigold, 0.6 )
    ]


seedsRight : List ( Int, SeedType, Float )
seedsRight =
    [ ( 10, Foxglove, 0.6 )
    , ( 2, Marigold, 0.7 )
    , ( 8, Sunflower, 0.5 )
    , ( 6, Rose, 1 )
    , ( 4, Lupin, 0.8 )
    ]
