module Scenes.Level.TopBar exposing
    ( TopBarViewModel
    , remainingMoves
    , renderScoreIcon
    , topBar
    )

import Css.Animation exposing (animation, delay, ease)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (transitionAll)
import Data.Board.Scores as Scores
import Data.Board.Types exposing (..)
import Data.Level.Setting exposing (TileSetting)
import Data.Window exposing (Window)
import Html exposing (..)
import Html.Attributes exposing (class)
import Svg exposing (Svg)
import Views.Board.Styles exposing (boardFullWidth, boardWidth, scoreIconSize, topBarHeight)
import Views.Icons.RainBank exposing (rainBankFull)
import Views.Icons.SunBank exposing (sunBankFull)
import Views.Icons.Tick exposing (tickBackground)
import Views.Seed.All exposing (renderSeed)


type alias TopBarViewModel =
    { window : Window
    , remainingMoves : Int
    , tileSettings : List TileSetting
    , scores : Scores.Scores
    }


topBar : TopBarViewModel -> Html msg
topBar model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , style
            [ height topBarHeight
            , color gold
            , backgroundColor washedYellow
            ]
        ]
        [ div
            [ style
                [ width <| toFloat <| boardFullWidth model.window
                , height topBarHeight
                ]
            , class "flex items-center justify-center relative"
            ]
            [ remainingMoves model.remainingMoves
            , div
                [ style
                    [ marginTop -16
                    , paddingHorizontal 0
                    , paddingVertical 9
                    ]
                , class "flex justify-center"
                ]
              <|
                List.map (renderScore model) (Scores.tileTypes model.tileSettings)
            ]
        ]


renderScore : TopBarViewModel -> TileType -> Html msg
renderScore model tileType =
    let
        scoreMargin =
            scoreIconSize // 2
    in
    div
        [ class "relative tc"
        , style
            [ marginRight <| toFloat scoreMargin
            , marginLeft <| toFloat scoreMargin
            ]
        ]
        [ renderScoreIcon tileType scoreIconSize
        , p
            [ class "ma0 absolute left-0 right-0 f6"
            , Html.Attributes.style "bottom" "-1.5em"
            ]
            [ scoreContent tileType model.scores ]
        ]


remainingMoves : Int -> Html msg
remainingMoves moves =
    div
        [ style [ left 8 ], class "absolute top-1" ]
        [ div
            [ style
                [ width 20
                , height 20
                , paddingAll 17
                ]
            , class "br-100 flex items-center justify-center"
            ]
            [ p
                [ class "ma0 f3"
                , style
                    [ color <| moveCounterColor moves
                    , transitionAll 1000 []
                    ]
                ]
                [ text <| String.fromInt moves ]
            ]
        , p
            [ style [ color darkYellow ]
            , class "ma0 tracked f7 mt1 tc"
            ]
            [ text "moves" ]
        ]


moveCounterColor : Int -> String
moveCounterColor moves =
    if moves > 5 then
        lightGreen

    else if moves > 2 then
        fadedOrange

    else
        pinkRed


scoreContent : TileType -> Scores.Scores -> Html msg
scoreContent tileType scores =
    if Scores.getScoreFor tileType scores == Just 0 then
        tickFadeIn tileType scores

    else
        text <| Scores.toString tileType scores


tickFadeIn : TileType -> Scores.Scores -> Html msg
tickFadeIn tileType scores =
    div [ class "relative" ]
        [ div
            [ style
                [ top 1
                , transform [ scale 0 ]
                , animation "bulge" 600 [ ease, delay 800 ]
                ]
            , class "absolute top-0 left-0 right-0"
            ]
            [ tickBackground ]
        , div
            [ style
                [ opacity 1
                , animation "fade-out" 500 [ ease ]
                ]
            ]
            [ text <| Scores.toString tileType scores ]
        ]


renderScoreIcon : TileType -> Float -> Html msg
renderScoreIcon tileType iconSize =
    case scoreIcon tileType of
        Just icon ->
            div
                [ class "bg-center contain"
                , style
                    [ width iconSize
                    , height iconSize
                    ]
                ]
                [ icon ]

        Nothing ->
            span [] []


scoreIcon : TileType -> Maybe (Svg msg)
scoreIcon tileType =
    case tileType of
        Sun ->
            Just sunBankFull

        Rain ->
            Just rainBankFull

        Seed seedType ->
            Just <| renderSeed seedType

        _ ->
            Nothing
