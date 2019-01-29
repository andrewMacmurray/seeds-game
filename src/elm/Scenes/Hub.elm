module Scenes.Hub exposing
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

import Browser.Dom as Dom
import Context exposing (Context)
import Css.Animation exposing (animation, ease, infinite)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Data.Board.Scores as Scores
import Data.Board.Types exposing (..)
import Data.InfoWindow as InfoWindow exposing (..)
import Data.Level.Setting exposing (TargetScore(..), TileSetting)
import Data.Levels as Levels
import Data.Lives as Lives
import Data.Progress as Progress
import Data.Transit exposing (Transit(..))
import Data.Window exposing (Window)
import Dict
import Exit exposing (continue, exitWith)
import Helpers.Attribute as Attribute
import Helpers.Delay exposing (sequence)
import Helpers.Sine exposing (wave)
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Scenes.Tutorial as Tutorial
import Task exposing (Task)
import Views.Icons.Heart as Heart
import Views.Icons.Triangle exposing (triangle)
import Views.InfoWindow exposing (infoContainer)
import Views.Lives exposing (renderLivesLeft)
import Views.Menu as Menu
import Views.Seed.All exposing (renderSeed)
import Views.Seed.Mono exposing (greyedOutSeed)
import Worlds



-- Model


type alias Model =
    { context : Context
    , infoWindow : InfoWindow Levels.Key
    }


type Msg
    = ShowLevelInfo Levels.Key
    | HideLevelInfo
    | SetInfoState (InfoWindow Levels.Key)
    | SetCurrentLevel Levels.Key
    | ScrollHubTo Levels.Key
    | ClearCurrentLevel
    | StartLevel Levels.Key
    | ExitToLevel Levels.Key
    | ExitToGarden
    | DomNoOp (Result Dom.Error ())


type Destination
    = ToLevel Levels.Key
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


init : Levels.Key -> Context -> ( Model, Cmd Msg )
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
    , infoWindow = InfoWindow.hidden
    }



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInfoState infoWindow ->
            continue { model | infoWindow = infoWindow } []

        ShowLevelInfo levelProgress ->
            continue { model | infoWindow = InfoWindow.visible levelProgress } []

        HideLevelInfo ->
            continue model
                [ sequence
                    [ ( 0, SetInfoState <| InfoWindow.leaving model.infoWindow )
                    , ( 1000, SetInfoState <| InfoWindow.hidden )
                    ]
                ]

        ScrollHubTo level ->
            continue model [ scrollHubToLevel level ]

        SetCurrentLevel level ->
            continue { model | context = Context.setCurrentLevel level model.context } []

        ClearCurrentLevel ->
            continue { model | context = Context.clearCurrentLevel model.context } []

        DomNoOp _ ->
            continue model []

        StartLevel level ->
            continue model
                [ sequence
                    [ ( 0, SetCurrentLevel level )
                    , ( 10, SetInfoState <| InfoWindow.leaving model.infoWindow )
                    , ( 600, SetInfoState <| InfoWindow.hidden )
                    , ( 100, ExitToLevel level )
                    ]
                ]

        ExitToLevel level ->
            exitWith (ToLevel level) model

        ExitToGarden ->
            exitWith ToGarden model



-- Update Helpers


scrollHubToLevel : Levels.Key -> Cmd Msg
scrollHubToLevel level =
    Levels.toId level
        |> Dom.getElement
        |> Task.andThen scrollLevelToView
        |> Task.attempt DomNoOp


scrollLevelToView : Dom.Element -> Task Dom.Error ()
scrollLevelToView { element, viewport } =
    Dom.setViewportOf "hub" 0 <| element.y - viewport.height / 2



-- View


view : Model -> Html Msg
view model =
    div [ handleHideInfo model ]
        [ renderTopBar model
        , renderInfoWindow model
        , div
            [ id "hub"
            , style
                [ height <| toFloat model.context.window.height
                , paddingTop 60
                ]
            , class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            ]
            (renderWorlds model)
        ]


renderTopBar : Model -> Html msg
renderTopBar model =
    let
        lives =
            model.context.lives
                |> Lives.remaining
                |> Transitioning
                |> renderLivesLeft
    in
    div
        [ style [ background washedYellow ]
        , class "w-100 fixed z-3 top-0 tc pa1 pa2-ns"
        ]
        [ div [ style [ transform [ scale 0.5 ] ] ] lives
        , div [ style [ color darkYellow ], class "f7" ]
            [ renderCountDown model.context.lives ]
        ]


renderCountDown : Lives.Lives -> Html msg
renderCountDown lives =
    case Lives.timeTillNextLife lives of
        Nothing ->
            p [ class "ma1 mt0" ] [ text "full life" ]

        Just t ->
            div []
                [ p [ style [ marginTop -2 ], class "dib ma1 mt0" ] [ text "Next life in: " ]
                , p [ style [ color pinkRed ], class "dib ma1 mt0" ] [ text <| renderTime t ]
                ]


renderTime : Lives.TimeTillNextLife -> String
renderTime { minutes, seconds } =
    String.fromInt minutes ++ ":" ++ renderSecond seconds


renderSecond : Int -> String
renderSecond n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n



-- Info Window


renderInfoWindow : Model -> Html Msg
renderInfoWindow { infoWindow, context } =
    let
        level =
            InfoWindow.content infoWindow |> Maybe.withDefault Levels.empty
    in
    case InfoWindow.state infoWindow of
        InfoWindow.Hidden ->
            span [] []

        InfoWindow.Visible ->
            infoContainer infoWindow <| div [ handleStartLevel context level ] <| infoContent context level

        InfoWindow.Leaving ->
            infoContainer infoWindow <| div [] <| infoContent context level


handleStartLevel context level =
    Attribute.applyIf (Lives.remaining context.lives > 0) <| onClick <| StartLevel level


infoContent : Context -> Levels.Key -> List (Html msg)
infoContent context level =
    if Lives.remaining context.lives > 0 then
        let
            levelText =
                Worlds.number level
                    |> Maybe.map String.fromInt
                    |> Maybe.map ((++) "Level ")
                    |> Maybe.withDefault ""

            icons =
                Worlds.getLevel level
                    |> Maybe.map infoIcons
                    |> Maybe.withDefault (span [] [])
        in
        [ p [ style [ marginTop 20 ], class "f5 tracked" ] [ text levelText ]
        , icons
        , p
            [ style
                [ backgroundColor gold
                , marginBottom 20
                , marginTop 15
                ]
            , class "tracked-mega pv2 ph3 dib br4"
            ]
            [ text "PLAY" ]
        ]

    else
        renderWaitForNextLife context


renderWaitForNextLife : Context -> List (Html msg)
renderWaitForNextLife context =
    let
        timeTillNextLife =
            Lives.timeTillNextLife context.lives
                |> Maybe.map renderTime
                |> Maybe.withDefault ""
    in
    [ div [ style [ paddingTop 50, paddingBottom 40 ], class "tracked f4 flex flex-column items-center" ]
        [ p [ class "ma0" ] [ text "Next life in" ]
        , p [ style [ color <| rgb 255 226 92, marginTop 25, marginBottom 30 ] ]
            [ text timeTillNextLife
            ]
        , div [ style [ width 40, height 40 ] ] [ Heart.beating ]
        ]
    ]


infoIcons : Levels.Level -> Html msg
infoIcons level =
    Levels.config level
        |> .tiles
        |> List.filter Scores.collectable
        |> List.map renderIcon
        |> infoIconsContainer


infoIconsContainer : List (Html msg) -> Html msg
infoIconsContainer =
    div
        [ style
            [ marginTop 25
            , marginBottom 15
            ]
        , class "flex justify-center items-end"
        ]


renderIcon : TileSetting -> Html msg
renderIcon { targetScore, tileType } =
    let
        tileIcon =
            case tileType of
                Rain ->
                    renderWeather lightBlue

                Sun ->
                    renderWeather orange

                Seed seedType ->
                    div [ style [ width 35, height 53 ] ] [ renderSeed seedType ]

                _ ->
                    span [] []
    in
    div [ class "dib mh3" ]
        [ div [ class "center flex flex-column" ]
            [ tileIcon
            , renderTargetScore targetScore
            ]
        ]


renderTargetScore : Maybe TargetScore -> Html msg
renderTargetScore ts =
    case ts of
        Just (TargetScore t) ->
            p [ style [ marginTop 10 ], class "f6 mb0" ] [ text <| String.fromInt t ]

        Nothing ->
            span [] []


renderWeather : String -> Html msg
renderWeather color =
    div
        [ style
            [ width 25
            , height 25
            , marginLeft 2.5
            , marginRight 2.5
            , marginBottom 5
            , background color
            ]
        , classes [ "br-100" ]
        ]
        []


handleHideInfo : Model -> Attribute Msg
handleHideInfo model =
    case InfoWindow.state model.infoWindow of
        InfoWindow.Visible ->
            onClick HideLevelInfo

        _ ->
            Attribute.empty



-- Worlds


renderWorlds : Model -> List (Html Msg)
renderWorlds model =
    List.map (renderWorld model) <| List.reverse Worlds.list


renderWorld : Model -> ( Levels.WorldConfig, List Levels.Key ) -> Html Msg
renderWorld model ( config, levels ) =
    div [ style [ backgroundColor config.backdropColor ], class "pa5 flex" ]
        [ div
            [ style [ width 300 ], class "center" ]
            (List.reverse levels |> List.indexedMap (renderLevel model config))
        ]


renderLevel : Model -> Levels.WorldConfig -> Int -> Levels.Key -> Html Msg
renderLevel model config index level =
    let
        reachedLevel =
            Progress.reachedLevel model.context.progress

        levelNumber =
            Worlds.number level |> Maybe.withDefault 1

        hasReachedLevel =
            Levels.reached reachedLevel level

        isCurrentLevel =
            level == reachedLevel
    in
    div
        [ styles
            [ [ width 35
              , marginTop 50
              , marginBottom 50
              , color config.textColor
              , Style.applyIf hasReachedLevel Style.pointer
              ]
            , offsetStyles <| index + 1
            ]
        , showInfo level model
        , class "tc relative"
        , id <| Levels.toId level
        ]
        [ currentLevelPointer isCurrentLevel
        , renderLevelIcon level config.seedType model
        , renderNumber levelNumber hasReachedLevel config
        ]


currentLevelPointer : Bool -> Html msg
currentLevelPointer isCurrentLevel =
    if isCurrentLevel then
        div
            [ style
                [ top -30
                , animation "hover" 1500 [ ease, infinite ]
                ]
            , class "absolute left-0 right-0"
            ]
            [ triangle ]

    else
        span [] []


offsetStyles : Int -> List Style
offsetStyles levelNumber =
    wave
        { center = [ leftAuto, rightAuto ]
        , right = [ leftAuto ]
        , left = []
        }
        (levelNumber - 1)


renderNumber : Int -> Bool -> Levels.WorldConfig -> Html Msg
renderNumber visibleLevelNumber hasReachedLevel config =
    if hasReachedLevel then
        div
            [ style
                [ backgroundColor config.textBackgroundColor
                , marginTop 10
                , width 25
                , height 25
                ]
            , class "br-100 center flex justify-center items-center"
            ]
            [ p [ style [ color config.textCompleteColor ], class "f6" ] [ text <| String.fromInt visibleLevelNumber ] ]

    else
        p [ style [ color config.textColor ] ]
            [ text <| String.fromInt visibleLevelNumber ]


showInfo : Levels.Key -> Model -> Attribute Msg
showInfo level model =
    let
        shouldShowInfo =
            Levels.reached (Progress.reachedLevel model.context.progress) level && InfoWindow.state model.infoWindow == Hidden
    in
    Attribute.applyIf shouldShowInfo <| onClick <| ShowLevelInfo level


renderLevelIcon : Levels.Key -> SeedType -> Model -> Html msg
renderLevelIcon level seedType model =
    if Levels.completed (Progress.reachedLevel model.context.progress) level then
        renderSeed seedType

    else
        greyedOutSeed
