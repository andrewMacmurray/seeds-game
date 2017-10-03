module Scenes.Hub.State exposing (..)

import Data.Hub.Config exposing (hubData)
import Data.Hub.LoadLevel exposing (handleLoadLevel)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber, getSelectedProgress, handleIncrementProgress)
import Data.Hub.Transition exposing (genRandomBackground)
import Data.Ports exposing (getExternalAnimations, receiveExternalAnimations, receiveHubLevelOffset, scrollToHubLevel)
import Helpers.Effect exposing (getWindowSize, scrollHubToLevel, sequenceMs, trackMouseDowns, trackMousePosition, trackWindowSize, trigger)
import Mouse
import Scenes.Hub.Types as Main exposing (..)
import Scenes.Level.State as Level
import Scenes.Level.Types as LevelModel exposing (Msg(ExitLevel))
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
    , externalAnimations = ""
    , scene = Title
    , sceneTransition = False
    , transitionBackground = Orange
    , progress = ( 1, 5 )
    , currentLevel = Nothing
    , infoWindow = Hidden
    , hubData = hubData
    , window = { height = 0, width = 0 }
    , mouse = { y = 0, x = 0 }
    }


update : Main.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
update msg model =
    case msg of
        LevelMsg levelMsg ->
            handleLevelMsg levelMsg model

        ReceieveExternalAnimations animations ->
            { model | externalAnimations = animations } ! []

        StartLevel level ->
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
                        [ ( 0, SetCurrentLevel Nothing )
                        , ( 0, IncrementProgress )
                        , ( 10, BeginSceneTransition )
                        , ( 500, SetScene Hub )
                        , ( 1000, ScrollToHubLevel <| (levelNumber model) + 1 )
                        , ( 1500, EndSceneTransition )
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
                        , ( 100, ScrollToHubLevel <| levelNumber model )
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
                    getSelectedProgress model |> Maybe.withDefault ( 1, 1 )
            in
                model
                    ! [ sequenceMs
                            [ ( 0, SetInfoState <| Leaving selectedLevel )
                            , ( 1000, SetInfoState Hidden )
                            ]
                      ]

        RandomBackground background ->
            { model | transitionBackground = background } ! []

        IncrementProgress ->
            (model |> handleIncrementProgress) ! []

        ScrollToHubLevel level ->
            model ! [ scrollToHubLevel level ]

        ReceiveHubLevelOffset offset ->
            model ! [ scrollHubToLevel offset model.window ]

        DomNoOp _ ->
            model ! []

        WindowSize size ->
            { model
                | levelModel = addWindowSizeToLevel size model
                , window = size
            }
                ! []

        MousePosition position ->
            { model | levelModel = addMousePositionToLevel position model } ! []


addMousePositionToLevel : Mouse.Position -> Main.Model -> LevelModel.Model
addMousePositionToLevel position { levelModel } =
    { levelModel | mouse = position }


addWindowSizeToLevel : Window.Size -> Main.Model -> LevelModel.Model
addWindowSizeToLevel window { levelModel } =
    { levelModel | window = window }


handleLevelMsg : LevelModel.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLevelMsg levelMsg model =
    case levelMsg of
        ExitLevel ->
            model ! [ trigger EndLevel ]

        _ ->
            let
                ( levelModel, levelCmd ) =
                    Level.update levelMsg model.levelModel
            in
                { model | levelModel = levelModel } ! [ levelCmd |> Cmd.map LevelMsg ]


levelNumber : Main.Model -> Int
levelNumber model =
    getLevelNumber model.progress model.hubData


subscriptions : Main.Model -> Sub Main.Msg
subscriptions model =
    Sub.batch
        [ trackWindowSize
        , trackMousePosition model
        , trackMouseDowns
        , receiveExternalAnimations ReceieveExternalAnimations
        , receiveHubLevelOffset ReceiveHubLevelOffset
        ]
