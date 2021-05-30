module Scene.Hub exposing
    ( Destination(..)
    , Model
    , Msg
    , getContext
    , init
    , menuOptions
    , update
    , updateContext
    , view
    )

import Board.Scores as Scores
import Board.Tile as Tile
import Config.Level as Level
import Config.World as Worlds
import Context exposing (Context)
import Countdown
import Element exposing (..)
import Element.Animations as Animations
import Element.Background as Background
import Element.Button as Button
import Element.Dot as Dot
import Element.Events exposing (onClick)
import Element.Icon.Triangle as Triangle
import Element.Info as Info
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Exit exposing (continue, exitWith)
import Html exposing (Html)
import Level.Progress as Progress
import Level.Setting.Tile as Tile exposing (TargetScore)
import Lives exposing (Lives)
import Ports.Scroll as Scroll
import Seed exposing (Seed)
import Sine
import Utils.Animated as Animated
import Utils.Delay exposing (sequence)
import Utils.Element as Element
import View.Menu as Menu
import View.Seed as Seed
import View.Seed.Mono exposing (greyedOutSeed)



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
    | ScrollHubTo Level.Id
    | ClearCurrentLevel
    | PlayLevelClicked Level.Id
    | ExitToLevel Level.Id
    | ExitToGarden
    | ScrolledToLevel


type Destination
    = ToLevel Level.Id
    | ToGarden



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option ExitToGarden "Garden"
    ]



-- Init


init : Level.Id -> Context -> ( Model, Cmd Msg )
init level context =
    ( initialState context
    , sequence
        [ ( 1000, ScrollHubTo level )
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
        SetInfoState infoWindow ->
            continue { model | info = infoWindow } []

        LevelClicked levelProgress ->
            continue { model | info = Info.visible levelProgress } []

        DismissInfoClicked ->
            continue model
                [ sequence
                    [ ( 0, SetInfoState (Info.leaving model.info) )
                    , ( 1000, SetInfoState Info.hidden )
                    ]
                ]

        ScrollHubTo level ->
            continue model [ scrollHubToLevel level ]

        SetCurrentLevel level ->
            continue { model | context = Context.setCurrentLevel level model.context } []

        ClearCurrentLevel ->
            continue { model | context = Context.clearCurrentLevel model.context } []

        ScrolledToLevel ->
            continue model []

        PlayLevelClicked level ->
            continue model
                [ sequence
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


scrollHubToLevel : Level.Id -> Cmd Msg
scrollHubToLevel level =
    Scroll.toCenter (Level.toString level)



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ inFront (topBar model)
        , handleDismiss model
        , inFront (viewInfo model)
        ]
        (renderWorlds model)


topBar : Model -> Element msg
topBar model =
    column
        [ width fill
        , Palette.background1
        , padding Scale.small
        ]
        [ el [ centerX, scale 0.5 ] (html (Lives.view model.context.lives))
        , el [ centerX ] (countdown model.context.lives)
        ]


countdown : Lives -> Element msg
countdown lives =
    case Lives.timeTillNextLife lives of
        Nothing ->
            Text.text [ Text.small ] "Full Life"

        Just t ->
            row []
                [ Text.text [ Text.small ] "Next life in: "
                , Text.text [ Text.small, Text.color Palette.pinkRed ] (Countdown.view t)
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
            , centerX
            ]
            [ Text.text [ Text.white, centerX, Text.spaced ] (levelLabel level)
            , levelIcons level
            , el [ centerX ] (Button.decorative [ Button.gold ] "PLAY")
            ]

    else
        renderWaitForNextLife context


levelIcons : Level.Id -> Element msg
levelIcons =
    Worlds.getLevel
        >> Maybe.map infoIcons
        >> Maybe.withDefault none


levelLabel : Level.Id -> String
levelLabel level =
    "Level " ++ String.fromInt (Worlds.number level)


renderWaitForNextLife : Context -> Element msg
renderWaitForNextLife context =
    none


infoIcons : Level.Level -> Element msg
infoIcons =
    Level.config
        >> .tileSettings
        >> List.filter Scores.collectible
        >> List.map renderIcon
        >> infoIconContainer


infoIconContainer : List (Element msg) -> Element msg
infoIconContainer =
    row [ spacing Scale.large, centerX ]


renderIcon : Tile.Setting -> Element msg
renderIcon setting =
    column [ spacing Scale.small ]
        [ el [ height (px 55), centerX ] (el [ alignBottom ] (tileIcon setting))
        , el [ centerX ] (renderTargetScore setting.targetScore)
        ]


tileIcon : Tile.Setting -> Element msg
tileIcon setting =
    case setting.tileType of
        Tile.Rain ->
            renderWeather Palette.blue5

        Tile.Sun ->
            renderWeather Palette.orange

        Tile.Seed seed ->
            seedIcon seed

        _ ->
            none


seedIcon : Seed -> Element msg
seedIcon seed =
    el
        [ width (px 35)
        , height (px 53)
        ]
        (html (Seed.view seed))


renderTargetScore : Maybe TargetScore -> Element msg
renderTargetScore ts =
    case ts of
        Just (Tile.TargetScore t) ->
            Text.text [ Text.white ] (String.fromInt t)

        Nothing ->
            none


renderWeather : Color -> Element msg
renderWeather color =
    el [ paddingXY 0 Scale.extraSmall ]
        (Dot.solid
            { size = 25
            , color = color
            }
        )


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
            , width (fill |> maximum 300)
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
        Animated.el Animations.hover [ centerX ] Triangle.icon

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
        html (Seed.view model.seed)

    else
        html greyedOutSeed


reachedLevel : Model -> Level.Id
reachedLevel model =
    Progress.reachedLevel model.context.progress
