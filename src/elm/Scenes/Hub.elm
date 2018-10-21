module Scenes.Hub exposing
    ( Model
    , Msg
    , getShared
    , init
    , update
    , updateShared
    , view
    )

import Browser.Dom as Dom
import Css.Animation exposing (animation, ease, infinite)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Types exposing (..)
import Data.Exit as Exit exposing (continue, exitWith)
import Data.InfoWindow as InfoWindow exposing (..)
import Data.Level.Types exposing (..)
import Data.Levels as Levels
import Data.Lives as Lives
import Data.Transit exposing (Transit(..))
import Data.Wave exposing (wave)
import Dict
import Helpers.Attribute as Attribute
import Helpers.Delay exposing (sequence)
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Scenes.Tutorial as Tutorial
import Shared exposing (Window)
import Task exposing (Task)
import Views.Icons.Triangle exposing (triangle)
import Views.InfoWindow exposing (infoContainer)
import Views.Lives exposing (renderLivesLeft)
import Views.Seed.All exposing (renderSeed)
import Worlds



-- MODEL


type alias Model =
    { shared : Shared.Data
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
    | DomNoOp (Result Dom.Error ())



-- Shared


getShared : Model -> Shared.Data
getShared model =
    model.shared


updateShared : (Shared.Data -> Shared.Data) -> Model -> Model
updateShared f model =
    { model | shared = f model.shared }



-- INIT


init : Levels.Key -> Shared.Data -> ( Model, Cmd Msg )
init level shared =
    ( initialState shared
    , sequence
        [ ( 1000, ScrollHubTo level )
        , ( 1000, ClearCurrentLevel )
        ]
    )


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , infoWindow = InfoWindow.hidden
    }



-- UPDATE


update : Msg -> Model -> Exit.With Levels.Key ( Model, Cmd Msg )
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
            continue { model | shared = Shared.setCurrentLevel level model.shared } []

        ClearCurrentLevel ->
            continue { model | shared = Shared.clearCurrentLevel model.shared } []

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
            exitWith level model []



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



-- VIEW


view : Model -> Html Msg
view model =
    div [ handleHideInfo model ]
        [ renderTopBar model
        , renderInfoWindow model
        , div
            [ id "hub"
            , style [ height <| toFloat model.shared.window.height ]
            , class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            ]
            (renderWorlds model)
        ]


renderTopBar : Model -> Html msg
renderTopBar model =
    let
        lives =
            model.shared.lives
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
            [ renderCountDown model.shared.lives ]
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



-- INFO WINDOW


renderInfoWindow : Model -> Html Msg
renderInfoWindow { infoWindow } =
    let
        level =
            InfoWindow.content infoWindow |> Maybe.withDefault Levels.empty
    in
    case InfoWindow.state infoWindow of
        InfoWindow.Hidden ->
            span [] []

        InfoWindow.Visible ->
            infoContainer infoWindow <| div [ onClick <| StartLevel level ] <| infoContent level

        InfoWindow.Leaving ->
            infoContainer infoWindow <| div [] <| infoContent level


infoContent : Levels.Key -> List (Html msg)
infoContent level =
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


infoIcons : Levels.Level -> Html msg
infoIcons level =
    Levels.config level
        |> .tiles
        |> List.filter collectable
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
            Attribute.emptyProperty



-- WORLDS


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
        levelNumber =
            Worlds.number level |> Maybe.withDefault 1

        hasReachedLevel =
            Levels.reached model.shared.progress level

        isCurrentLevel =
            level == model.shared.progress
    in
    div
        [ styles
            [ [ width 35
              , marginTop 50
              , marginBottom 50
              , color config.textColor
              ]
            , offsetStyles <| index + 1
            ]
        , showInfo level model
        , class "tc pointer relative"
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
    if Levels.reached model.shared.progress level && InfoWindow.state model.infoWindow == Hidden then
        onClick <| ShowLevelInfo level

    else
        Attribute.emptyProperty


handleStartLevel : Levels.Key -> Model -> Attribute Msg
handleStartLevel level model =
    if Levels.reached model.shared.progress level then
        onClick <| StartLevel level

    else
        Attribute.emptyProperty


renderLevelIcon : Levels.Key -> SeedType -> Model -> Html msg
renderLevelIcon level seedType model =
    if Levels.completed model.shared.progress level then
        renderSeed seedType

    else
        renderSeed GreyedOut
