module Scene.Level.View.TopBar exposing
    ( ViewModel
    , scoreIcon
    , view
    )

import Board.Scores as Scores exposing (Scores)
import Board.Tile as Tile exposing (Tile)
import Css.Animation exposing (animation, delay, ease)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition as Transition exposing (transition, transitionAll)
import Html exposing (..)
import Html.Attributes exposing (class)
import Level.Setting.Tile as Tile
import Scene.Level.Challenge as Challenge exposing (Challenge)
import Scene.Level.Sky as Sky
import Scene.Level.View.Board.Style as Board
import Svg exposing (Svg)
import Utils.Time.Clock as Clock
import View.Icon.RainBank exposing (rainBankFull)
import View.Icon.SunBank exposing (sunBankFull)
import View.Icon.Tick exposing (tickBackground)
import View.Seed as Seed
import Window exposing (Window)



-- Model


type alias ViewModel =
    { window : Window
    , challenge : Challenge
    , tileSettings : List Tile.Setting
    , scores : Scores
    }



-- View


view : ViewModel -> Html msg
view model =
    div
        [ class "no-select w-100 flex items-center justify-center fixed top-0 z-3"
        , style
            [ height Board.topBarHeight
            , topBarTextColor model.challenge
            , topBarBackground model.challenge
            ]
        ]
        [ div
            [ style
                [ width <| toFloat <| Board.fullWidth model.window
                , height Board.topBarHeight
                ]
            , class "flex items-center justify-center relative"
            ]
            [ renderChallenge model.challenge
            , div
                [ style
                    [ marginTop -16
                    , paddingHorizontal 0
                    , paddingVertical 9
                    ]
                , class "flex justify-center"
                ]
                (List.map (renderScore model) (Scores.tileTypes model.tileSettings))
            ]
        ]


topBarTextColor : Challenge -> Style
topBarTextColor challenge =
    case challenge of
        Challenge.TimeLimit timeRemaining ->
            Style.compose
                [ color <| Sky.textColor timeRemaining
                , transitionAll 3000 [ Transition.linear ]
                ]

        Challenge.MoveLimit _ ->
            color gold


topBarBackground : Challenge -> Style
topBarBackground challenge =
    case challenge of
        Challenge.TimeLimit timeRemaining ->
            Style.compose
                [ backgroundColor <| Sky.alternateColor timeRemaining
                , transitionAll 3000 [ Transition.linear ]
                ]

        Challenge.MoveLimit _ ->
            backgroundColor washedYellow


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



-- Challenge


renderChallenge : Challenge -> Html msg
renderChallenge challenge =
    case challenge of
        Challenge.MoveLimit moves ->
            remainingMoves moves

        Challenge.TimeLimit time ->
            remainingTime time


remainingTime : Challenge.TimeRemaining -> Html msg
remainingTime timeRemaining =
    div
        [ style [ left -13 ], class "absolute top-1" ]
        [ div
            [ style
                [ width 20
                , height 20
                , paddingAll 17
                ]
            ]
            [ p [ class "ma0 f5 tracked-mega" ]
                [ text (showTime timeRemaining) ]
            ]
        ]


showTime : Challenge.TimeRemaining -> String
showTime timeRemaining =
    let
        { minutes, seconds } =
            timeRemaining
                |> Challenge.clock
                |> Clock.render
    in
    minutes ++ ":" ++ seconds


remainingMoves : Challenge.MovesRemaining -> Html msg
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


scoreContent : Tile -> Scores -> Html msg
scoreContent tileType scores =
    if Scores.getFor tileType scores == Just 0 then
        tickFadeIn tileType scores

    else
        text <| scoreFor tileType scores


tickFadeIn : Tile -> Scores -> Html msg
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
            [ text <| scoreFor tileType scores ]
        ]


scoreFor : Tile -> Scores -> String
scoreFor tileType scores =
    Scores.getFor tileType scores
        |> Maybe.map String.fromInt
        |> Maybe.withDefault ""


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
