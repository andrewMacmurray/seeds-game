module Scenes.Hub.State exposing (..)

import Config.AllLevels exposing (allLevels)
import Config.Scale as ScaleConfig
import Config.Text exposing (randomSuccessMessageIndex)
import Data.Hub.Progress exposing (..)
import Data.Hub.Transition exposing (genRandomBackground)
import Data.Ports exposing (..)
import Data.Transit as Transit exposing (Transit(..))
import Helpers.Effect exposing (..)
import Helpers.OutMsg exposing (returnWithOutMsg)
import Mouse
import Scenes.Hub.Types as Main exposing (..)
import Scenes.Level.State as Level
import Scenes.Level.Types as Lv
    exposing
        ( Msg(RandomSuccessMessageIndex)
        , OutMsg(ExitLevelWithWin, ExitLevelWithLose)
        )
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types as Tu
    exposing
        ( Msg(ResetVisibilities, StartSequence)
        , OutMsg(ExitTutorialToLevel)
        )
import Types exposing (..)
import Window


init : ( Main.Model, Cmd Main.Msg )
init =
    let
        ( model, loadLevelCmd ) =
            handleLoadLevel initialState <| getLevelData initialState.progress
    in
        model
            ! [ getWindowSize
              , getExternalAnimations ScaleConfig.baseTileSizeY
              , randomSuccessMessageIndex RandomSuccessMessageIndex |> Cmd.map LevelMsg
              , loadLevelCmd
              ]


initialState : Main.Model
initialState =
    { levelModel = Level.initialState
    , tutorialModel = Tutorial.initialState
    , xAnimations = ""
    , scene = Title
    , sceneTransition = False
    , transitionBackground = Orange
    , progress = ( 1, 1 )
    , currentLevel = Nothing
    , lives = Stationary 5
    , infoWindow = Hidden
    , window = { height = 0, width = 0 }
    , mouse = { y = 0, x = 0 }
    }


update : Main.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
update msg model =
    case msg of
        LevelMsg levelMsg ->
            handleLevelMsg levelMsg model

        TutorialMsg tutorialMsg ->
            handleTutorialMsg tutorialMsg model

        ReceieveExternalAnimations animations ->
            { model | xAnimations = animations } ! []

        StartLevel level ->
            case tutorialData level of
                Just tutorialConfig ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, BeginSceneTransition )
                                , ( 500, SetScene Tutorial )
                                , ( 0, LoadLevelData <| getLevelData level )
                                , ( 0, TutorialMsg ResetVisibilities )
                                , ( 2500, EndSceneTransition )
                                , ( 500, TutorialMsg <| StartSequence tutorialConfig )
                                ]
                          ]

                Nothing ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, BeginSceneTransition )
                                , ( 500, SetScene Level )
                                , ( 0, LoadLevelData <| getLevelData level )
                                , ( 2500, EndSceneTransition )
                                ]
                          ]

        RestartLevel ->
            model
                ! [ sequenceMs
                        [ ( 10, BeginSceneTransition )
                        , ( 500, SetScene Level )
                        , ( 0, LoadLevelData <| currentLevelData model )
                        , ( 2500, EndSceneTransition )
                        ]
                  ]

        TransitionWithWin ->
            model ! [ sequenceMs <| levelWinSequence model ]

        TransitionWithLose ->
            model ! [ sequenceMs <| levelLoseSequence model ]

        LoadLevelData levelData ->
            handleLoadLevel model levelData

        SetScene scene ->
            { model | scene = scene } ! []

        BeginSceneTransition ->
            { model | sceneTransition = True } ! [ genRandomBackground ]

        EndSceneTransition ->
            { model | sceneTransition = False } ! []

        SetCurrentLevel progress ->
            { model | currentLevel = progress } ! []

        GoToHub ->
            model
                ! [ sequenceMs
                        [ ( 0, BeginSceneTransition )
                        , ( 500, SetScene Hub )
                        , ( 100, ScrollToHubLevel <| progressLevelNumber model )
                        , ( 2400, EndSceneTransition )
                        ]
                  ]

        GoToRetry ->
            { model | scene = Retry, lives = Transit.toStationary model.lives } ! []

        SetInfoState infoWindow ->
            { model | infoWindow = infoWindow } ! []

        ShowInfo levelProgress ->
            { model | infoWindow = Visible levelProgress } ! []

        HideInfo ->
            let
                selectedLevel =
                    getSelectedProgress model.infoWindow |> Maybe.withDefault ( 1, 1 )
            in
                model
                    ! [ sequenceMs
                            [ ( 0, SetInfoState <| Hiding selectedLevel )
                            , ( 1000, SetInfoState Hidden )
                            ]
                      ]

        RandomBackground background ->
            { model | transitionBackground = background } ! []

        IncrementProgress ->
            handleIncrementProgress model ! []

        DecrementLives ->
            { model | lives = decrementLives model.lives } ! []

        ScrollToHubLevel level ->
            model ! [ scrollToHubLevel level ]

        ReceiveHubLevelOffset offset ->
            model ! [ scrollHubToLevel offset model.window ]

        DomNoOp _ ->
            model ! []

        WindowSize size ->
            { model
                | levelModel = addWindowSizeToLevel size model
                , tutorialModel = addWindowSizeToTutorial size model
                , window = size
            }
                ! [ getExternalAnimations <| ScaleConfig.baseTileSizeY * ScaleConfig.tileScaleFactor size ]

        MousePosition position ->
            { model | levelModel = addMousePositionToLevel position model } ! []


currentLevelData : Model -> LevelData
currentLevelData model =
    model.currentLevel
        |> Maybe.withDefault ( 1, 1 )
        |> getLevelData


decrementLives : Transit Int -> Transit Int
decrementLives lifeState =
    lifeState
        |> Transit.map (\n -> n - 1)
        |> Transit.toTransitioning


handleLoadLevel : Main.Model -> LevelData -> ( Main.Model, Cmd Main.Msg )
handleLoadLevel model levelData =
    let
        ( levelModel, levelCmd ) =
            Level.init levelData model.levelModel
    in
        { model | levelModel = levelModel } ! [ Cmd.map LevelMsg levelCmd ]


tutorialData : Progress -> Maybe Tu.Config
tutorialData level =
    let
        ( _, levelData ) =
            getLevelConfig level
    in
        levelData.tutorial


addMousePositionToLevel : Mouse.Position -> Main.Model -> Lv.Model
addMousePositionToLevel position { levelModel } =
    { levelModel | mouse = position }


addWindowSizeToLevel : Window.Size -> Main.Model -> Lv.Model
addWindowSizeToLevel window { levelModel } =
    { levelModel | window = window }


addWindowSizeToTutorial : Window.Size -> Main.Model -> Tu.Model
addWindowSizeToTutorial window { tutorialModel } =
    { tutorialModel | window = window }


handleLevelMsg : Lv.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLevelMsg levelMsg model =
    Level.update levelMsg model.levelModel
        |> returnWithOutMsg (embedLevelModel model) LevelMsg
        |> handleLevelOutMsg


handleLevelOutMsg : ( Main.Model, Cmd Main.Msg, Maybe Lv.OutMsg ) -> ( Main.Model, Cmd Main.Msg )
handleLevelOutMsg ( model, cmd, outMsg ) =
    case outMsg of
        Just ExitLevelWithWin ->
            model ! [ trigger TransitionWithWin, cmd ]

        Just ExitLevelWithLose ->
            model ! [ trigger TransitionWithLose, cmd ]

        Nothing ->
            model ! [ cmd ]


embedLevelModel : Main.Model -> (Lv.Model -> Main.Model)
embedLevelModel model levelModel =
    { model | levelModel = levelModel }


handleTutorialMsg : Tu.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleTutorialMsg tutorialMsg m =
    Tutorial.update tutorialMsg m.tutorialModel
        |> returnWithOutMsg (embedTutorialModel m) TutorialMsg
        |> handleTutorialOutMsg


handleTutorialOutMsg : ( Main.Model, Cmd Main.Msg, Maybe Tu.OutMsg ) -> ( Main.Model, Cmd Main.Msg )
handleTutorialOutMsg ( model, cmd, outMsg ) =
    case outMsg of
        Just ExitTutorialToLevel ->
            if not model.tutorialModel.skipped then
                { model | scene = Level } ! [ cmd ]
            else
                model ! [ cmd ]

        Nothing ->
            model ! [ cmd ]


embedTutorialModel : Main.Model -> (Tu.Model -> Main.Model)
embedTutorialModel model tutorialModel =
    { model | tutorialModel = tutorialModel }


handleIncrementProgress : Main.Model -> Main.Model
handleIncrementProgress model =
    { model | progress = incrementProgress model.currentLevel model.progress }


progressLevelNumber : Main.Model -> Int
progressLevelNumber model =
    getLevelNumber model.progress allLevels


levelWinSequence : Main.Model -> List ( Float, Main.Msg )
levelWinSequence model =
    let
        backToHub =
            backToHubSequence <| levelCompleteScrollNumber model
    in
        if shouldIncrement model.currentLevel model.progress then
            [ ( 0, SetScene Summary )
            , ( 2000, IncrementProgress )
            , ( 2500, BeginSceneTransition )
            ]
                ++ backToHub
        else
            ( 0, BeginSceneTransition ) :: backToHub


levelLoseSequence : Main.Model -> List ( Float, Main.Msg )
levelLoseSequence model =
    [ ( 0, GoToRetry )
    , ( 1000, DecrementLives )
    ]


backToHubSequence : Int -> List ( Float, Main.Msg )
backToHubSequence levelNumber =
    [ ( 500, SetScene Hub )
    , ( 1000, ScrollToHubLevel levelNumber )
    , ( 1500, EndSceneTransition )
    , ( 500, SetCurrentLevel Nothing )
    ]


levelCompleteScrollNumber : Main.Model -> Int
levelCompleteScrollNumber model =
    if shouldIncrement model.currentLevel model.progress then
        progressLevelNumber model + 1
    else
        getLevelNumber (Maybe.withDefault ( 1, 1 ) model.currentLevel) allLevels


subscriptions : Main.Model -> Sub Main.Msg
subscriptions model =
    Sub.batch
        [ trackWindowSize
        , trackMousePosition model
        , trackMouseDowns
        , receiveExternalAnimations ReceieveExternalAnimations
        , receiveHubLevelOffset ReceiveHubLevelOffset
        ]
