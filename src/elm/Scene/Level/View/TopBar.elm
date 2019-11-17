module Scene.Level.View.TopBar exposing
    ( ViewModel
    , scoreIcon
    , view
    )

import Board.Scores as Scores
import Board.Tile as Tile exposing (Tile)
import Css.Animation exposing (animation, delay, ease)
import Css.Color exposing (..)
import Css.Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (transitionAll)
import Html exposing (..)
import Html.Attributes exposing (class)
import Level.Setting.Tile as Tile
import Scene.Level.View.Board.Style as Board
import Svg exposing (Svg)
import View.Icon.RainBank exposing (rainBankFull)
import View.Icon.SunBank exposing (sunBankFull)
import View.Icon.Tick exposing (tickBackground)
import View.Seed as Seed
import Window exposing (Window)



-- Model


type alias ViewModel =
    { window : Window
    , remainingMoves : Int
    , tileSettings : List Tile.Setting
    , scores : Scores.Scores
    }



-- View


view : ViewModel -> Html msg
view model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , style
            [ height Board.topBarHeight
            , color gold
            , backgroundColor washedYellow
            ]
        ]
        [ div
            [ style
                [ width <| toFloat <| Board.fullWidth model.window
                , height Board.topBarHeight
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


renderScore : ViewModel -> Tile -> Html msg
renderScore model tileType =
    let
        scoreMargin =
            Board.scoreIconSize // 2
    in
    div
        [ class "relative tc"
        , style
            [ marginRight <| toFloat scoreMargin
            , marginLeft <| toFloat scoreMargin
            ]
        ]
        [ scoreIcon tileType Board.scoreIconSize
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


scoreContent : Tile -> Scores.Scores -> Html msg
scoreContent tileType scores =
    if Scores.getScoreFor tileType scores == Just 0 then
        tickFadeIn tileType scores

    else
        text <| Scores.toString tileType scores


tickFadeIn : Tile -> Scores.Scores -> Html msg
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


scoreIcon : Tile -> Float -> Html msg
scoreIcon tileType iconSize =
    case scoreIcon_ tileType of
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


scoreIcon_ : Tile -> Maybe (Svg msg)
scoreIcon_ tileType =
    case tileType of
        Tile.Sun ->
            Just sunBankFull

        Tile.Rain ->
            Just rainBankFull

        Tile.Seed seed ->
            Just <| Seed.view seed

        _ ->
            Nothing
