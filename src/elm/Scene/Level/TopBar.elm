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
import Element.Seed as Seed
import Element.Text as Text
import Game.Board.Scores as Scores exposing (Scores)
import Game.Board.Tile as Tile exposing (Tile)
import Game.Level.Tile as Tile
import Scene.Level.Board as Board
import Seed exposing (Seed)
import Simple.Animation as Animation exposing (Animation)
import Simple.Animation.Property as P
import Svg exposing (Svg)
import Utils.Animated as Animated
import Utils.Element as Element
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
    { icon : Icon
    , score : Score
    }


type Icon
    = Sun
    | Rain
    | Seed Seed


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
        |> List.filterMap (toResource model)


toResource : Model -> Tile -> Maybe Resource
toResource model tile =
    case tile of
        Tile.Sun ->
            Just (toResource_ Sun model tile)

        Tile.Rain ->
            Just (toResource_ Rain model tile)

        Tile.Seed seed ->
            Just (toResource_ (Seed seed) model tile)

        _ ->
            Nothing


toResource_ : Icon -> Model -> Tile -> Resource
toResource_ icon model tile =
    { icon = icon
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
        , Element.preventScroll
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
        , Text.text [ Text.f6, Text.spaced, centerX ] "moves"
        ]


remainingMoves_ : ViewModel -> Element msg
remainingMoves_ model =
    Text.text
        [ Text.color model.color
        , Text.f3
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
    column [ spacing (Scale.extraSmall + Scale.extraSmall // 2) ]
        [ resourceIcon resource.icon
        , viewScore resource.score
        ]


resourceIcon : Icon -> Element msg
resourceIcon icon =
    el
        [ width (px Board.scoreIconSize)
        , height (px Board.scoreIconSize)
        ]
        (html (resourceIcon_ icon))


resourceIcon_ : Icon -> Svg msg
resourceIcon_ resource =
    case resource of
        Sun ->
            SunBank.full

        Rain ->
            RainBank.full

        Seed seed ->
            Seed.svg seed


viewScore : Score -> Element msg
viewScore score =
    case score of
        Remaining score_ ->
            textScore score_

        Complete ->
            scoreComplete


textScore : String -> Element msg
textScore =
    Text.text
        [ centerX
        , Text.color Palette.gold
        ]


scoreComplete : Element msg
scoreComplete =
    el [ behindContent fadingOutScore, centerX ] tick


fadingOutScore : Element msg
fadingOutScore =
    Animated.el fadeOut [ centerX ] (textScore "0")


tick : Element msg
tick =
    Animated.el bulge [ centerX ] (html Tick.icon)


bulge : Animation
bulge =
    Animation.fromTo
        { duration = 500
        , options = [ Animation.easeOutBack, Animation.delay 800 ]
        }
        [ P.scale 0 ]
        [ P.scale 1 ]


fadeOut : Animation
fadeOut =
    Animations.fadeOut 1000 []
