module Scenes.Intro.GrowingSeeds exposing
    ( State(..)
    , view
    )

import Css.Animation exposing (animation, delay, ease, easeOut)
import Css.Style exposing (Style, empty, marginLeft, marginRight, opacity, style, styles, transform, transformOrigin, width)
import Css.Transform as Transform
import Css.Transition as Transition exposing (transition)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (SeedType(..))
import Data.Window as Window exposing (Window, size)
import Helpers.Attribute as Attribute
import Html exposing (..)
import Html.Attributes exposing (class)
import Views.Seed.All exposing (renderSeed)


type State
    = Entering
    | Leaving


view : Window -> State -> Html msg
view window vis =
    let
        size =
            Window.size window
    in
    div [ class "flex justify-center" ] <|
        [ sideSeedsContainer vis <| List.reverse <| List.map (growingSeed window) (seedsLeft size)
        , div [ mainSeedStyles vis ] [ growingSeed window ( 0, Sunflower, 1.1 ) ]
        , sideSeedsContainer vis <| List.map (growingSeed window) (seedsRight size)
        ]


mainSeedStyles : State -> Attribute msg
mainSeedStyles vis =
    case vis of
        Leaving ->
            style
                [ animation "slide-down-scale-out" 2000 [ delay 500, ease ]
                , transformOrigin "bottom"
                ]

        _ ->
            Attribute.empty


sideSeedsContainer : State -> List (Html msg) -> Html msg
sideSeedsContainer vis =
    case vis of
        Leaving ->
            div [ class "o-0 flex justify-center", style [ transition "opacity" 1500 [] ] ]

        Entering ->
            div [ class "o-100 flex justify-center", style [ transition "opacity" 1500 [] ] ]


growingSeed : Window -> ( Int, SeedType, Float ) -> Html msg
growingSeed window ( index, seedType, scale ) =
    let
        delayMs =
            index * 100
    in
    div [ class "flex items-end" ]
        [ div
            [ style
                [ width <| 50 * scale * Tile.scale window
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


seedsLeft : Window.Size -> List ( Int, SeedType, Float )
seedsLeft screenSize =
    case screenSize of
        Window.Small ->
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


seedsRight : Window.Size -> List ( Int, SeedType, Float )
seedsRight screenSize =
    case screenSize of
        Window.Small ->
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
