module Scenes.Hub.State exposing (..)

import Config.AllLevels exposing (allLevels)
import Data.Hub.LoadLevel exposing (handleLoadLevel)
import Data.Hub.Progress exposing (..)
import Data.Hub.Transition exposing (genRandomBackground)
import Data.Ports exposing (..)
import Helpers.Effect exposing (..)
import Helpers.Scale exposing (tileScaleFactor)
import Mouse
import Scenes.Hub.Types as Main exposing (..)
import Scenes.Level.State as Level
import Scenes.Level.Types as LevelModel exposing (Msg(ExitLevel))
import Scenes.Tutorial.State as Tutorial
import Scenes.Tutorial.Types as TutorialModel exposing (Msg(..))
import Types exposing (..)
import Window


init : ( Main.Model, Cmd Main.Msg )
init =
    initialState
        ! [ getWindowSize
          , getExternalAnimations initialState.levelModel.tileSize.y
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
            case tutorialData model level of
                Just config ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, BeginSceneTransition )
                                , ( 500, SetScene Tutorial )
                                , ( 0, LoadLevelData <| getLevelConfig level model )
                                , ( 0, TutorialMsg ResetVisibilities )
                                , ( 2500, EndSceneTransition )
                                , ( 500, TutorialMsg <| StartSequence config )
                                ]
                          ]

                Nothing ->
                    model
                        ! [ sequenceMs
                                [ ( 600, SetCurrentLevel <| Just level )
                                , ( 10, BeginSceneTransition )
                                , ( 500, SetScene Level )
                                , ( 0, LoadLevelData <| getLevelConfig level model )
                                , ( 2500, EndSceneTransition )
                                ]
                          ]

        EndLevel ->
            model
                ! [ sequenceMs
                        [ ( 0, SetScene Summary )
                        , ( 2000, IncrementProgress )
                        , ( 2500, BeginSceneTransition )
                        , ( 500, SetScene Hub )
                        , ( 1000, ScrollToHubLevel <| levelCompleteScrollNumber model )
                        , ( 1500, EndSceneTransition )
                        , ( 500, SetCurrentLevel Nothing )
                        ]
                  ]

        LoadLevelData levelData ->
            handleLoadLevel levelData model

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
                        , ( 100, ScrollToHubLevel <| scrollToProgress model )
                        , ( 2400, EndSceneTransition )
                        ]
                  ]

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
                ! [ getExternalAnimations <| model.levelModel.tileSize.y * tileScaleFactor size ]

        MousePosition position ->
            { model | levelModel = addMousePositionToLevel position model } ! []


tutorialData : Main.Model -> Progress -> Maybe TutorialModel.InitConfig
tutorialData model level =
    let
        ( _, levelData ) =
            getLevelConfig level model
    in
        levelData.tutorial


addMousePositionToLevel : Mouse.Position -> Main.Model -> LevelModel.Model
addMousePositionToLevel position { levelModel } =
    { levelModel | mouse = position }


addWindowSizeToLevel : Window.Size -> Main.Model -> LevelModel.Model
addWindowSizeToLevel window { levelModel } =
    { levelModel | window = window }


addWindowSizeToTutorial : Window.Size -> Main.Model -> TutorialModel.Model
addWindowSizeToTutorial window { tutorialModel } =
    { tutorialModel | window = window }


handleLevelMsg : LevelModel.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLevelMsg levelMsg model =
    let
        ( levelModel, levelCmd_ ) =
            Level.update levelMsg model.levelModel

        newModel =
            { model | levelModel = levelModel }

        levelCmd =
            Cmd.map LevelMsg levelCmd_
    in
        case levelMsg of
            ExitLevel ->
                newModel ! [ trigger EndLevel, levelCmd ]

            _ ->
                newModel ! [ levelCmd ]


handleTutorialMsg : TutorialModel.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleTutorialMsg tutorialMsg model =
    let
        ( tutorialModel, tutorialCmd_ ) =
            Tutorial.update tutorialMsg model.tutorialModel

        newModel =
            { model | tutorialModel = tutorialModel }

        tutorialCmd =
            Cmd.map TutorialMsg tutorialCmd_
    in
        if tutorialMsg == ExitTutorial && not newModel.tutorialModel.skipped then
            { newModel | scene = Level } ! [ tutorialCmd ]
        else
            newModel ! [ tutorialCmd ]


handleIncrementProgress : Model -> Model
handleIncrementProgress model =
    { model | progress = incrementProgress model.currentLevel model.progress }


scrollToProgress : Main.Model -> Int
scrollToProgress model =
    getLevelNumber model.progress allLevels


levelCompleteScrollNumber : Main.Model -> Int
levelCompleteScrollNumber model =
    if shouldIncrement model.currentLevel model.progress then
        scrollToProgress model + 1
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
