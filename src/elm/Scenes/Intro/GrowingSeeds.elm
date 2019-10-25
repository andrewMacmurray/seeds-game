module Scenes.Intro.GrowingSeeds exposing
    ( State(..)
    , view
    )

import Board.Tile as Tile
import Css.Animation exposing (animation, delay, ease, easeOut)
import Css.Style exposing (..)
import Css.Transform as Transform
import Css.Transition exposing (transition)
import Html exposing (..)
import Html.Attributes exposing (class)
import Seed exposing (Seed(..))
import Utils.Attribute as Attribute
import Views.Seed as Seed
import Window exposing (Window, size)


type State
    = Entering
    | Leaving


view : Window -> State -> Html msg
view window vis =
    let
        size =
            Window.size window
    in
    div [ class "flex justify-center" ]
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


growingSeed : Window -> ( Int, Seed, Float ) -> Html msg
growingSeed window ( index, seed, scale ) =
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
            [ Seed.view seed ]
        ]


seedsLeft : Window.Size -> List ( Int, Seed, Float )
seedsLeft screenSize =
    case screenSize of
        Window.Small ->
            [ ( 3, Marigold, 0.7 )
            , ( 5, Chrysanthemum, 0.5 )
            , ( 1, Rose, 0.8 )
            , ( 7, Lupin, 0.5 )
            ]

        _ ->
            [ ( 3, Marigold, 0.7 )
            , ( 9, Chrysanthemum, 0.5 )
            , ( 7, Rose, 0.8 )
            , ( 1, Lupin, 1 )
            , ( 5, Marigold, 0.6 )
            ]


seedsRight : Window.Size -> List ( Int, Seed, Float )
seedsRight screenSize =
    case screenSize of
        Window.Small ->
            [ ( 4, Chrysanthemum, 0.6 )
            , ( 6, Marigold, 0.7 )
            , ( 2, Sunflower, 0.5 )
            , ( 8, Lupin, 0.5 )
            ]

        _ ->
            [ ( 10, Chrysanthemum, 0.6 )
            , ( 2, Marigold, 0.7 )
            , ( 8, Sunflower, 0.5 )
            , ( 6, Rose, 1 )
            , ( 4, Lupin, 0.8 )
            ]
