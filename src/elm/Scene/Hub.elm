module Scene.Hub exposing
    ( Destination(..)
    , Model
    , Msg
    , init
    , menuOptions
    , update
    , view
    )

import Context exposing (Context)
import Delay
import Element exposing (..)
import Element.Background as Background
import Element.Button as Button
import Element.Dot as Dot
import Element.Events exposing (onClick)
import Element.Icon.Heart as Heart
import Element.Icon.Triangle as Triangle
import Element.Info as Info
import Element.Layout as Layout
import Element.Menu as Menu
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Seed as Seed
import Element.Text as Text
import Element.Weather as Weather
import Exit exposing (continue, exitWith)
import Game.Board.Scores as Scores
import Game.Board.Tile as Tile
import Game.Config.Level as Level
import Game.Config.World as Worlds
import Game.Level.Progress as Progress
import Game.Level.Tile as Tile exposing (TargetScore)
import Game.Lives as Lives exposing (Lives)
import Ports.Scroll as Scroll
import Seed exposing (Seed)
import Utils.Element as Element
import Utils.Sine as Sine
import Utils.Time.Clock as Clock



-- Model


type alias Model =
    { context : Context
    , info : Info.State Level.Id
    }


type Msg
    = LevelClicked Level.Id
    | DismissInfoClicked
    | SetInfoState (Info.State Level.Id)
    | SetCurrentLevel Level.Id
    | ScrollToLevel Level.Id
    | ClearCurrentLevel
    | PlayLevelClicked Level.Id
    | ExitToLevel Level.Id
    | ExitToGarden


type Destination
    = ToLevel Level.Id
    | ToGarden



-- Menu


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option ExitToGarden "Garden"
    ]



-- Init


init : Level.Id -> Context -> ( Model, Cmd Msg )
init level context =
    ( initialState context
    , Delay.sequence
        [ ( 1000, ScrollToLevel level )
        , ( 1500, ClearCurrentLevel )
        ]
    )


initialState : Context -> Model
initialState context =
    { context = context
    , info = Info.hidden
    }



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInfoState info ->
            continue { model | info = info } []

        LevelClicked levelProgress ->
            continue { model | info = Info.visible levelProgress } []

        DismissInfoClicked ->
            continue model
                [ Delay.sequence
                    [ ( 0, SetInfoState (Info.leaving model.info) )
                    , ( 1000, SetInfoState Info.hidden )
                    ]
                ]

        ScrollToLevel level ->
            continue model [ scrollToLevel level ]

        SetCurrentLevel level ->
            continue { model | context = Context.setCurrentLevel level model.context } []

        ClearCurrentLevel ->
            continue { model | context = Context.clearCurrentLevel model.context } []

        PlayLevelClicked level ->
            continue model
                [ Delay.sequence
                    [ ( 0, SetCurrentLevel level )
                    , ( 10, SetInfoState (Info.leaving model.info) )
                    , ( 600, SetInfoState Info.hidden )
                    , ( 100, ExitToLevel level )
                    ]
                ]

        ExitToLevel level ->
            exitWith (ToLevel level) model

        ExitToGarden ->
            exitWith ToGarden model


scrollToLevel : Level.Id -> Cmd Msg
scrollToLevel =
    Scroll.toCenter << Level.toString



-- View


view : Model -> Layout.Scene Msg
view model =
    Layout.scrollable
        [ inFront (topBar model)
        , handleDismiss model
        , inFront (viewInfo model)
        ]
        (renderWorlds model)


topBar : Model -> Element msg
topBar model =
    column
        [ width fill
        , Palette.background2
        , padding Scale.small
        ]
        [ el [ centerX, scale 0.5 ] (Lives.view model.context.lives)
        , el [ centerX ] (countdown model.context.lives)
        ]


countdown : Lives -> Element msg
countdown lives =
    case Lives.timeTillNextLife lives of
        Nothing ->
            Text.text [ Text.f6 ] "Full Life"

        Just t ->
            row []
                [ Text.text [ Text.f6 ] "Next life in: "
                , Text.text [ Text.f6, Text.color Palette.pinkRed ] (Clock.readout t)
                ]



-- Info


viewInfo : Model -> Element Msg
viewInfo { info, context } =
    Info.view
        { content = infoContent context
        , info = info
        }


infoContent : Context -> Level.Id -> Element Msg
infoContent context level =
    if Lives.remaining context.lives > 0 then
        column
            [ spacing (Scale.medium + Scale.small)
            , onClick (PlayLevelClicked level)
            , pointer
            , centerX
            ]
            [ Text.text [ Text.white, centerX, Text.spaced ] (levelLabel level)
            , levelIcons level
            , el [ centerX ] (Button.decorative [ Button.gold ] "PLAY")
            ]

    else
        waitForNextLife context


levelIcons : Level.Id -> Element msg
levelIcons =
    Worlds.getLevel
        >> Maybe.map infoIcons
        >> Maybe.withDefault none


levelLabel : Level.Id -> String
levelLabel level =
    "Level " ++ String.fromInt (Worlds.number level)


waitForNextLife : Context -> Element msg
waitForNextLife context =
    column [ centerX, spacing Scale.medium ]
        [ Text.text [ Text.white, Text.spaced, centerX ] "Next life in "
        , Text.text [ centerX, Text.color Palette.lightGold ] (countdown_ context)
        , Element.square 40 [ centerX ] Heart.beating
        ]


countdown_ : Context -> String
countdown_ =
    .lives
        >> Lives.timeTillNextLife
        >> Maybe.map Clock.readout
        >> Maybe.withDefault ""


infoIcons : Level.Level -> Element msg
infoIcons =
    Level.config
        >> .tileSettings
        >> List.filter Scores.collectible
        >> List.map viewIcon
        >> infoIconContainer


infoIconContainer : List (Element msg) -> Element msg
infoIconContainer =
    row [ spacing (Scale.medium + Scale.small), centerX ]


viewIcon : Tile.Setting -> Element msg
viewIcon setting =
    column [ spacing Scale.small, width (px 50), height fill ]
        [ el [ centerX, alignBottom ] (tileIcon setting)
        , el [ centerX, alignBottom ] (viewTargetScore setting.targetScore)
        ]


tileIcon : Tile.Setting -> Element msg
tileIcon setting =
    case setting.tileType of
        Tile.Rain ->
            Weather.rain Weather.medium

        Tile.Sun ->
            Weather.sun
                { size = Weather.medium
                , shade = Weather.dark
                }

        Tile.Seed seed ->
            seedIcon seed

        _ ->
            none


seedIcon : Seed -> Element msg
seedIcon =
    Seed.view Seed.medium


viewTargetScore : Maybe TargetScore -> Element msg
viewTargetScore ts =
    case ts of
        Just (Tile.TargetScore t) ->
            Text.text [ Text.white ] (String.fromInt t)

        Nothing ->
            none


handleDismiss : Model -> Attribute Msg
handleDismiss model =
    if Info.isVisible model.info then
        onClick DismissInfoClicked

    else
        Element.empty



-- Worlds


renderWorlds : Model -> Element Msg
renderWorlds model =
    List.reverse Worlds.list
        |> List.map (renderWorld model)
        |> column [ width fill ]


renderWorld : Model -> Level.WorldWithLevels -> Element Msg
renderWorld model { world, levels } =
    el
        [ Background.color world.backdropColor
        , width fill
        , padding Scale.large
        ]
        (column
            [ centerX
            , spacing Scale.large
            , paddingXY Scale.medium Scale.extraLarge
            , width (fill |> maximum 325)
            ]
            (levels
                |> List.reverse
                |> List.indexedMap (toLevelModel model world)
                |> List.map renderLevel
            )
        )



-- Levels


type alias LevelModel =
    { label : String
    , level : Level.Id
    , textBackground : Color
    , textCompleteColor : Color
    , textColor : Color
    , index : Int
    , seed : Seed
    , clickActive : Bool
    , hasReachedLevel : Bool
    , hasCompletedLevel : Bool
    , isCurrentLevel : Bool
    }


toLevelModel : Model -> Level.WorldConfig -> Int -> Level.Id -> LevelModel
toLevelModel model config index level =
    { label = String.fromInt (Worlds.number level)
    , level = level
    , index = index
    , textBackground = config.textBackgroundColor
    , textCompleteColor = config.textCompleteColor
    , textColor = config.textColor
    , seed = config.seed
    , clickActive = Level.isReached (reachedLevel model) level && Info.isHidden model.info
    , hasReachedLevel = Level.isReached (reachedLevel model) level
    , hasCompletedLevel = Level.isCompleted (reachedLevel model) level
    , isCurrentLevel = level == reachedLevel model
    }


renderLevel : LevelModel -> Element Msg
renderLevel model =
    column
        (List.append (offsetStyles model)
            [ width (px 35)
            , above (currentLevelPointer model)
            , paddingXY 0 Scale.medium
            , spacing Scale.small
            , Element.id (Level.toString model.level)
            , Element.applyIf model.hasReachedLevel pointer
            , Element.onClickIf model.clickActive (LevelClicked model.level)
            ]
        )
        [ el [] (levelIcon model)
        , el [ centerX ] (renderNumber model)
        ]


currentLevelPointer : LevelModel -> Element msg
currentLevelPointer model =
    if model.isCurrentLevel then
        Triangle.hovering [ centerX ]

    else
        none


offsetStyles : LevelModel -> List (Attribute msg)
offsetStyles model =
    Sine.wave
        { center = [ centerX ]
        , right = [ alignRight ]
        , left = [ alignLeft ]
        }
        model.index


renderNumber : LevelModel -> Element Msg
renderNumber model =
    if model.hasReachedLevel then
        Dot.el
            { size = 25
            , color = model.textBackground
            }
            (Text.text [ Text.color model.textCompleteColor ] model.label)

    else
        Text.text [ Text.color model.textColor ] model.label


levelIcon : LevelModel -> Element msg
levelIcon model =
    if model.hasCompletedLevel then
        Seed.view Seed.fill model.seed

    else
        Seed.grey Seed.fill


reachedLevel : Model -> Level.Id
reachedLevel model =
    Progress.reachedLevel model.context.progress
