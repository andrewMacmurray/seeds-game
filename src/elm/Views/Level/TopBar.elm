module Views.Level.TopBar exposing (..)

import Config.Color exposing (..)
import Config.Scale as ScaleConfig
import Data2.Level.Score exposing (getScoreFor, scoreTileTypes, scoreToString)
import Data2.Tile exposing (TileType(..))
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Scenes.Level.Types as Level exposing (..)
import Views.Icons.Tick exposing (tickBackground)
import Views.Level.Styles exposing (boardFullWidth, boardWidth, seedBackgrounds)


topBar : Level.Model -> Html msg
topBar model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , style
            [ heightStyle ScaleConfig.topBarHeight
            , color gold
            , backgroundColor washedYellow
            ]
        ]
        [ div
            [ style [ widthStyle <| boardFullWidth model, heightStyle ScaleConfig.topBarHeight ]
            , class "flex items-center justify-center relative"
            ]
            [ remainingMoves model.remainingMoves
            , div [ style [ marginTop -16, ( "padding", "0 9px" ) ], class "flex justify-center" ] <|
                List.map (renderScore model) (scoreTileTypes model.tileSettings)
            ]
        ]


renderScore : Level.Model -> TileType -> Html msg
renderScore model tileType =
    let
        scoreMargin =
            ScaleConfig.scoreIconSize // 2
    in
        div
            [ class "relative tc"
            , style
                [ marginRight scoreMargin
                , marginLeft scoreMargin
                ]
            ]
            [ renderScoreIcon tileType
            , p
                [ class "ma0 absolute left-0 right-0 f6"
                , style [ ( "bottom", "-1.5em" ) ]
                ]
                [ scoreContent tileType model.scores ]
            ]


remainingMoves : Int -> Html msg
remainingMoves remainingMoves =
    div
        [ style [ leftStyle 8 ], class "absolute top-1" ]
        [ div
            [ style
                [ widthStyle 20
                , heightStyle 20
                , paddingAll 17
                ]
            , class "br-100 flex items-center justify-center"
            ]
            [ p
                [ class "ma0 f3"
                , style
                    [ color <| moveCounterColor remainingMoves
                    , transitionStyle "1s ease"
                    ]
                ]
                [ text <| toString remainingMoves ]
            ]
        , p [ style [ color darkYellow ], class "ma0 tracked f7 mt1 tc" ] [ text "moves" ]
        ]


moveCounterColor : Int -> String
moveCounterColor remainingMoves =
    if remainingMoves > 5 then
        lightGreen
    else if remainingMoves > 2 then
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
                [ topStyle 1
                , transformStyle <| scale 0
                , animationStyle "bulge 0.6s ease"
                , fillForwards
                , animationDelayStyle 800
                ]
            , class "absolute top-0 left-0 right-0"
            ]
            [ tickBackground ]
        , div
            [ style
                [ animationStyle "fade-out 0.5s linear"
                , fillForwards
                , opacityStyle 1
                ]
            ]
            [ text <| scoreToString tileType scores ]
        ]


renderScoreIcon : TileType -> Html msg
renderScoreIcon tileType =
    scoreIcon tileType ScaleConfig.scoreIconSize


scoreIcon : TileType -> number -> Html msg
scoreIcon tileType scoreIconSize =
    case scoreIconUrl tileType of
        Just url ->
            div
                [ class "bg-center contain"
                , style
                    [ backgroundImage url
                    , widthStyle scoreIconSize
                    , heightStyle scoreIconSize
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
