module Scenes.Hub exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Browser.Dom as Dom
import Config.Levels exposing (allLevels, getLevelConfig)
import Css.Animation exposing (animation, ease, infinite)
import Css.Color exposing (..)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Data.Board.Score exposing (collectable, scoreTileTypes)
import Data.Board.Types exposing (..)
import Data.InfoWindow as InfoWindow exposing (..)
import Data.Level.Progress exposing (..)
import Data.Level.Types exposing (..)
import Data.Transit exposing (Transit(..))
import Data.Window as Window
import Dict
import Exit exposing (continue, exitWith)
import Helpers.Delay exposing (delay, sequence)
import Helpers.Html exposing (emptyProperty)
import Helpers.Wave exposing (wave)
import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Scenes.Tutorial as Tutorial
import Shared
import Task exposing (Task)
import Views.Icons.Triangle exposing (triangle)
import Views.InfoWindow exposing (infoContainer)
import Views.Lives exposing (renderLivesLeft)
import Views.Seed.All exposing (renderSeed)



-- MODEL


type alias Model =
    { shared : Shared.Data
    , infoWindow : InfoWindow Progress
    }


type Msg
    = ShowLevelInfo Progress
    | HideLevelInfo
    | SetInfoState (InfoWindow Progress)
    | ScrollHubToLevel Int
    | StartLevel Progress
    | DomNoOp (Result Dom.Error ())



-- INIT


init : Int -> Shared.Data -> ( Model, Cmd Msg )
init levelNumber shared =
    ( initialState shared
    , delay 1000 <| ScrollHubToLevel levelNumber
    )


initialState : Shared.Data -> Model
initialState shared =
    { shared = shared
    , infoWindow = InfoWindow.hidden
    }



-- UPDATE


update : Msg -> Model -> Exit.With Progress ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInfoState infoWindow ->
            continue { model | infoWindow = infoWindow } []

        ShowLevelInfo levelProgress ->
            continue { model | infoWindow = InfoWindow.show levelProgress } []

        HideLevelInfo ->
            continue model
                [ sequence
                    [ ( 0, SetInfoState <| InfoWindow.leave model.infoWindow )
                    , ( 1000, SetInfoState InfoWindow.hidden )
                    ]
                ]

        ScrollHubToLevel level ->
            continue model [ scrollHubToLevel level ]

        DomNoOp _ ->
            continue model []

        StartLevel level ->
            exitWith level model []



-- Update Helpers


scrollHubToLevel : Int -> Cmd Msg
scrollHubToLevel levelNumber =
    getLevelId levelNumber
        |> Dom.getElement
        |> Task.andThen scrollLevelToView
        |> Task.attempt DomNoOp


scrollLevelToView : Dom.Element -> Task Dom.Error ()
scrollLevelToView { element, viewport } =
    Dom.setViewportOf "hub" 0 <| element.y - viewport.height / 2


getLevelId : Int -> String
getLevelId levelNumber =
    "level-" ++ String.fromInt levelNumber



-- VIEW


view : Model -> Html Msg
view model =
    div [ handleHideInfo model ]
        [ hubTopBar model
        , info model
        , div
            [ id "hub"
            , style [ height <| toFloat model.shared.window.height ]
            , class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
            ]
            (renderWorlds model)
        ]


hubTopBar : Model -> Html msg
hubTopBar model =
    -- FIXME
    -- let
    --     lives =
    --         model.timeTillNextLife
    --             |> livesLeft
    --             |> floor
    --             |> Transitioning
    -- in
    div
        [ style [ background washedYellow ]
        , class "w-100 fixed z-3 top-0 tc pa1 pa2-ns"
        ]
        [ div [ style [ transform [ scale 0.5 ] ] ] <| renderLivesLeft <| Transitioning 5
        , div [ style [ color darkYellow ], class "f7" ]
            -- FIXME add time from model
            [ renderCountDown 0 ]
        ]


renderCountDown : Float -> Html msg
renderCountDown timeRemaining =
    case timeLeft timeRemaining of
        Nothing ->
            p [ class "ma1 mt0" ] [ text "full life" ]

        Just t ->
            div []
                [ p [ style [ marginTop -2 ], class "dib ma1 mt0" ] [ text "Next life in: " ]
                , p [ style [ color pinkRed ], class "dib ma1 mt0" ] [ text <| renderTime t ]
                ]


renderTime : ( Int, Int ) -> String
renderTime ( m, s ) =
    String.fromInt m ++ ":" ++ renderSecond s


timeLeft : Float -> Maybe ( Int, Int )
timeLeft timeRemaining =
    -- let
    --     d =
    --         Date.fromTime timeRemaining
    -- in
    -- FIXME
    if timeRemaining == 0 then
        Nothing

    else
        -- Just ( modBy 5 (minute d), second d )
        Just ( 1, 1 )


renderSecond : Int -> String
renderSecond n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n



-- INFO WINDOW


info : Model -> Html Msg
info { infoWindow } =
    let
        progress =
            val infoWindow |> Maybe.withDefault ( 1, 1 )

        content =
            getLevelConfig progress |> infoContent progress
    in
    if isHidden infoWindow then
        span [] []

    else if isVisible infoWindow then
        infoContainer infoWindow <| div [ onClick <| StartLevel progress ] content

    else
        infoContainer infoWindow <| div [] content


infoContent : Progress -> CurrentLevelConfig tutorialConfig -> List (Html msg)
infoContent ( world, level ) ( worldData, levelData ) =
    let
        levelText =
            levelNumber allLevels ( world, level )
                |> String.fromInt
                |> (++) "Level "
    in
    [ p [ style [ marginTop 20 ], class "f5 tracked" ] [ text levelText ]
    , infoIcons levelData worldData.seedType
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


infoIcons : LevelData tutorialConfig -> SeedType -> Html msg
infoIcons levelData seedType =
    levelData.tileSettings
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
    if isVisible model.infoWindow then
        onClick HideLevelInfo

    else
        emptyProperty



-- WORLDS


renderWorlds : Model -> List (Html Msg)
renderWorlds model =
    allLevels
        |> Dict.toList
        |> List.reverse
        |> List.map (renderWorld model)


renderWorld : Model -> ( WorldNumber, WorldData Tutorial.Config ) -> Html Msg
renderWorld model (( _, worldData ) as world) =
    div [ style [ backgroundColor worldData.background ], class "pa5 flex" ]
        [ div
            [ style [ width 300 ], class "center" ]
            (worldData.levels
                |> Dict.toList
                |> List.reverse
                |> List.map (renderLevel model world)
            )
        ]


renderLevel :
    Model
    -> ( WorldNumber, WorldData Tutorial.Config )
    -> ( LevelNumber, LevelData Tutorial.Config )
    -> Html Msg
renderLevel model ( world, worldData ) ( level, levelData ) =
    let
        ln =
            levelNumber allLevels ( world, level )

        hasReachedLevel =
            reachedLevel allLevels ( world, level ) model.shared.progress

        isCurrentLevel =
            ( world, level ) == model.shared.progress
    in
    div
        [ styles
            [ [ width 35
              , marginTop 50
              , marginBottom 50
              , color worldData.textColor
              ]
            , offsetStyles level
            ]
        , showInfo ( world, level ) model
        , class "tc pointer relative"
        , id <| "level-" ++ String.fromInt ln
        ]
        [ currentLevelPointer isCurrentLevel
        , renderLevelIcon ( world, level ) worldData.seedType model
        , renderNumber ln hasReachedLevel worldData
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


renderNumber : Int -> Bool -> WorldData Tutorial.Config -> Html Msg
renderNumber visibleLevelNumber hasReachedLevel worldData =
    if hasReachedLevel then
        div
            [ style
                [ backgroundColor worldData.textBackgroundColor
                , marginTop 10
                , width 25
                , height 25
                ]
            , class "br-100 center flex justify-center items-center"
            ]
            [ p [ style [ color worldData.textCompleteColor ], class "f6" ] [ text <| String.fromInt visibleLevelNumber ] ]

    else
        p [ style [ color worldData.textColor ] ] [ text <| String.fromInt visibleLevelNumber ]


showInfo : Progress -> Model -> Attribute Msg
showInfo currentLevel model =
    if reachedLevel allLevels currentLevel model.shared.progress && InfoWindow.isHidden model.infoWindow then
        onClick <| ShowLevelInfo currentLevel

    else
        emptyProperty


handleStartLevel : Progress -> Model -> Attribute Msg
handleStartLevel currentLevel model =
    if reachedLevel allLevels currentLevel model.shared.progress then
        onClick <| StartLevel currentLevel

    else
        emptyProperty


renderLevelIcon : ( WorldNumber, LevelNumber ) -> SeedType -> Model -> Html msg
renderLevelIcon currentLevel seedType model =
    if completedLevel allLevels currentLevel model.shared.progress then
        renderSeed seedType

    else
        renderSeed GreyedOut
