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

import Config.Color exposing (..)
import Config.Scale as ScaleConfig
import Data.Board.Score exposing (getScoreFor, scoreTileTypes, scoreToString)
import Data.Board.Types exposing (..)
import Helpers.Css.Animation exposing (..)
import Helpers.Css.Style as Style exposing (..)
import Helpers.Css.Timing exposing (..)
import Helpers.Css.Transform exposing (..)
import Helpers.Css.Transition exposing (easeAll)
import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Level.Types exposing (LevelModel)
import Views.Icons.Tick exposing (tickBackground)
import Views.Level.Styles exposing (boardFullWidth, boardWidth, seedBackgrounds)


topBar : LevelModel -> Html msg
topBar model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , styleAttr (heightStyle ScaleConfig.topBarHeight)
        , styleAttr (color gold)
        , styleAttr (backgroundColor washedYellow)
        ]
        [ div
            [ styleAttr (width <| toFloat <| boardFullWidth model)
            , styleAttr (heightStyle ScaleConfig.topBarHeight)
            , class "flex items-center justify-center relative"
            ]
            [ remainingMoves model.remainingMoves
            , Style.batch div
                [ [ marginTop -16 ]
                , paddingHorizontal 0
                , paddingVertical 9
                ]
                [ class "flex justify-center" ]
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
        , styleAttr (marginRight <| toFloat scoreMargin)
        , styleAttr (marginLeft <| toFloat scoreMargin)
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
        [ styleAttr (leftStyle 8), class "absolute top-1" ]
        [ div
            [ styleAttr (width 20)
            , styleAttr (heightStyle 20)
            , styleAttr (paddingAll 17)
            , class "br-100 flex items-center justify-center"
            ]
            [ p
                [ class "ma0 f3"
                , styleAttr (color <| moveCounterColor moves)
                , styleAttr (easeAll 1000)
                ]
                [ text <| String.fromInt moves ]
            ]
        , p [ styleAttr (color darkYellow), class "ma0 tracked f7 mt1 tc" ] [ text "moves" ]
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
            [ styleAttr (topStyle 1)
            , styleAttr (transform [ scale 0 ])
            , styleAttr
                (animationWithOptionsStyle
                    { name = "bulge"
                    , duration = 600
                    , delay = Just 800
                    , timing = Ease
                    , fill = Forwards
                    , iteration = Nothing
                    }
                )
            , class "absolute top-0 left-0 right-0"
            ]
            [ tickBackground ]
        , div
            [ styleAttr (animateEase "fade-out" 500)
            , styleAttr (opacityStyle 1)
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
                , styleAttr (backgroundImage url)
                , styleAttr (width scoreIconSize)
                , styleAttr (heightStyle scoreIconSize)
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
