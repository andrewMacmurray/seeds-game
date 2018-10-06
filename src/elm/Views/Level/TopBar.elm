module Views.Level.TopBar exposing
    ( moveCounterColor
    , remainingMoves
    , renderScore
    , renderScoreIcon
    , scoreContent
    , scoreIcon
    , scoreIconUrl
    , tickFadeIn
    , topBar
    )

import Config.Scale as ScaleConfig
import Css.Animation exposing (animation, delay, ease)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Timing exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (easeAll)
import Data.Board.Score exposing (getScoreFor, scoreTileTypes, scoreToString)
import Data.Board.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (LevelModel)
import Views.Icons.Tick exposing (tickBackground)
import Views.Level.Styles exposing (boardFullWidth, boardWidth, seedBackgrounds)


topBar : LevelModel -> Html msg
topBar model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , style
            [ height ScaleConfig.topBarHeight
            , color gold
            , backgroundColor washedYellow
            ]
        ]
        [ div
            [ style
                [ width <| toFloat <| boardFullWidth model
                , height ScaleConfig.topBarHeight
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
                List.map (renderScore model) (scoreTileTypes model.tileSettings)
            ]
        ]


renderScore : LevelModel -> TileType -> Html msg
renderScore model tileType =
    let
        scoreMargin =
            ScaleConfig.scoreIconSize // 2
    in
    div
        [ class "relative tc"
        , style
            [ marginRight <| toFloat scoreMargin
            , marginLeft <| toFloat scoreMargin
            ]
        ]
        [ renderScoreIcon tileType
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
                    , easeAll 1000
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


scoreContent : TileType -> Scores -> Html msg
scoreContent tileType scores =
    if getScoreFor tileType scores == Just 0 then
        tickFadeIn tileType scores

    else
        text <| scoreToString tileType scores


tickFadeIn : TileType -> Scores -> Html msg
tickFadeIn tileType scores =
    div [ class "relative" ]
        [ div
            [ style
                [ top 1
                , transform [ scale 0 ]
                , animation "bulge" 600 |> ease |> delay 800
                ]
            , class "absolute top-0 left-0 right-0"
            ]
            [ tickBackground ]
        , div
            [ style
                [ opacity 1
                , animation "fade-out" 500 |> ease
                ]
            ]
            [ text <| scoreToString tileType scores ]
        ]


renderScoreIcon : TileType -> Html msg
renderScoreIcon tileType =
    scoreIcon tileType ScaleConfig.scoreIconSize


scoreIcon : TileType -> Float -> Html msg
scoreIcon tileType scoreIconSize =
    case scoreIconUrl tileType of
        Just url ->
            div
                [ class "bg-center contain"
                , style
                    [ backgroundImage url
                    , width scoreIconSize
                    , height scoreIconSize
                    ]
                ]
                []

        Nothing ->
            span [] []


scoreIconUrl : TileType -> Maybe String
scoreIconUrl tileType =
    case tileType of
        Sun ->
            Just "img/sun.svg"

        Rain ->
            Just "img/rain.svg"

        Seed seedType ->
            Just <| seedBackgrounds seedType

        _ ->
            Nothing
