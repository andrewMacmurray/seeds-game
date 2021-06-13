module Scene.Level.TopBar exposing
    ( Model
    , view
    )

import Element exposing (..)
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Game.Board.Scores as Scores
import Game.Level.Setting.Tile as Tile
import Scene.Level.Board as Board
import Window exposing (Window)



-- Top Bar


type alias Model =
    { window : Window
    , remainingMoves : Int
    , tileSettings : List Tile.Setting
    , scores : Scores.Scores
    }



-- View


view : Model -> Element msg
view model =
    el
        [ width fill
        , height (px Board.topBarHeight)
        , Palette.background2
        ]
        (row
            [ centerX
            , height fill
            , width (px (Board.fullWidth model.window))
            , paddingXY Scale.extraSmall 0
            ]
            [ remainingMoves model ]
        )


remainingMoves : Model -> Element msg
remainingMoves model =
    column [ spacing Scale.extraSmall ]
        [ remainingMoves_ model
        , Text.text [ Text.small, Text.spaced, centerX ] "moves"
        ]


remainingMoves_ : Model -> Element msg
remainingMoves_ model =
    Text.text
        [ Text.color (remainingMovesColor model)
        , Text.large
        , centerX
        ]
        (String.fromInt model.remainingMoves)


remainingMovesColor : Model -> Color
remainingMovesColor model =
    if model.remainingMoves > 5 then
        Palette.green5

    else if model.remainingMoves > 2 then
        Palette.gold

    else
        Palette.crimson



--renderScore : Model -> Tile -> Html msg
--renderScore model tileType =
--    let
--        scoreMargin =
--            Board.scoreIconSize // 2
--    in
--    div
--        [ class "relative tc"
--        , style
--            [ marginRight (toFloat scoreMargin)
--            , marginLeft (toFloat scoreMargin)
--            ]
--        ]
--        [ scoreIcon tileType Board.scoreIconSize
--        , p
--            [ class "ma0 absolute left-0 right-0 f6"
--            , Html.Attributes.style "bottom" "-1.5em"
--            ]
--            [ scoreContent tileType model.scores ]
--        ]
--
--
--scoreContent : Tile -> Scores.Scores -> Html msg
--scoreContent tileType scores =
--    if Scores.getScoreFor tileType scores == Just 0 then
--        tickFadeIn tileType scores
--
--    else
--        text (Scores.toString tileType scores)
--
--
--tickFadeIn : Tile -> Scores.Scores -> Html msg
--tickFadeIn tileType scores =
--    div [ class "relative" ]
--        [ div
--            [ style
--                [ top 1
--                , transform [ scale 0 ]
--                , animation "bulge" 600 [ ease, delay 800 ]
--                ]
--            , class "absolute top-0 left-0 right-0"
--            ]
--            [ Tick.icon ]
--        , div
--            [ style
--                [ opacity 1
--                , animation "fade-out" 500 [ ease ]
--                ]
--            ]
--            [ text (Scores.toString tileType scores) ]
--        ]
--
--
--scoreIcon : Tile -> Float -> Html msg
--scoreIcon tileType iconSize =
--    case scoreIcon_ tileType of
--        Just icon ->
--            div
--                [ class "bg-center contain"
--                , style
--                    [ width iconSize
--                    , height iconSize
--                    ]
--                ]
--                [ icon ]
--
--        Nothing ->
--            span [] []
--
--
--scoreIcon_ : Tile -> Maybe (Svg msg)
--scoreIcon_ tileType =
--    case tileType of
--        Tile.Sun ->
--            Just SunBank.full
--
--        Tile.Rain ->
--            Just RainBank.full
--
--        Tile.Seed seed ->
--            Just (Seed.view seed)
--
--        _ ->
--            Nothing
