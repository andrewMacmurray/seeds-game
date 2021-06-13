module Scene.Level.TopBar exposing
    ( Model
    , view
    )

import Element exposing (..)
import Element.Animations as Animations
import Element.Icon.RainBank as RainBank
import Element.Icon.SunBank as SunBank
import Element.Icon.Tick as Tick
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Game.Board.Scores as Scores exposing (Scores)
import Game.Board.Tile as Tile exposing (Tile)
import Game.Level.Setting.Tile as Tile
import Scene.Level.Board as Board
import Simple.Animation as Animation
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Element as Element
import View.Seed as Seed
import Window exposing (Window)



-- Top Bar


type alias Model =
    { window : Window
    , remainingMoves : Int
    , tileSettings : List Tile.Setting
    , scores : Scores
    }


type alias ViewModel =
    { remainingMoves : Int
    , color : Color
    , width : Int
    , resources : List Resource
    }


type alias Resource =
    { tile : Tile
    , score : Score
    }


type Score
    = Complete
    | Remaining String



-- View Model


toViewModel : Model -> ViewModel
toViewModel model =
    { remainingMoves = model.remainingMoves
    , color = remainingMovesColor model
    , width = Board.fullWidth model.window
    , resources = toResources model
    }


toResources : Model -> List Resource
toResources model =
    model.tileSettings
        |> Scores.tileTypes
        |> List.map (toResource model)


toResource : Model -> Tile -> Resource
toResource model tile =
    { tile = tile
    , score = toScore tile model.scores
    }


toScore : Tile -> Scores -> Score
toScore tile scores =
    if Scores.getScoreFor tile scores == Just 0 then
        Complete

    else
        Remaining (Scores.toString tile scores)



-- View


view : Model -> Element msg
view =
    toViewModel >> view_


view_ : ViewModel -> Element msg
view_ model =
    el
        [ width fill
        , height (px Board.topBarHeight)
        , Palette.background2
        ]
        (row
            [ centerX
            , height fill
            , width (px model.width)
            , paddingXY Scale.extraSmall 0
            ]
            [ remainingMoves model
            , resourceBanks model
            ]
        )



-- Remaining Moves


remainingMoves : ViewModel -> Element msg
remainingMoves model =
    column [ spacing Scale.extraSmall ]
        [ remainingMoves_ model
        , Text.text [ Text.small, Text.spaced, centerX ] "moves"
        ]


remainingMoves_ : ViewModel -> Element msg
remainingMoves_ model =
    Text.text
        [ Text.color model.color
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



-- Resource Banks


resourceBanks : ViewModel -> Element msg
resourceBanks model =
    row
        [ centerX
        , moveLeft (Board.scoreIconSize - 9)
        , spacing (round Board.scoreIconSize)
        ]
        (List.map viewBank model.resources)


viewBank : Resource -> Element msg
viewBank resource =
    Element.showIfJust (viewBank_ resource) (scoreIcon_ resource.tile)


viewBank_ : Resource -> Svg msg -> Element msg
viewBank_ resource icon_ =
    column [ spacing (Scale.extraSmall + Scale.extraSmall // 2) ]
        [ el
            [ width (px Board.scoreIconSize)
            , height (px Board.scoreIconSize)
            ]
            (html icon_)
        , viewScore resource.score
        ]


viewScore : Score -> Element msg
viewScore score =
    case score of
        Remaining score_ ->
            textScore score_

        Complete ->
            scoreComplete


textScore : String -> Element msg
textScore =
    Text.text [ centerX, Text.color Palette.gold ]


scoreComplete =
    el
        [ behindContent (Animated.el (Animations.fadeOut 1000 []) [ centerX ] (textScore "0"))
        , centerX
        ]
        (Animated.el bulge [ centerX ] (html Tick.icon))


bulge =
    Animation.fromTo
        { duration = 500
        , options = [ Animation.easeOutBack, Animation.delay 800 ]
        }
        [ P.scale 0 ]
        [ P.scale 1 ]



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


scoreIcon_ : Tile -> Maybe (Svg msg)
scoreIcon_ tileType =
    case tileType of
        Tile.Sun ->
            Just SunBank.full

        Tile.Rain ->
            Just RainBank.full

        Tile.Seed seed ->
            Just (Seed.view seed)

        _ ->
            Nothing
