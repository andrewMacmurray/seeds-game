module Update exposing (..)

import Data.Hub.LoadLevel exposing (handleLoadLevel)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber, getSelectedProgress, handleIncrementProgress)
import Data.Hub.Types exposing (..)
import Data.Ports exposing (getExternalAnimations, receiveExternalAnimations, receiveHubLevelOffset, scrollToHubLevel)
import Helpers.Effect exposing (..)
import Model as Main exposing (..)
import Mouse
import Scenes.Hub.Model as HubModel exposing (..)
import Scenes.Hub.Update as Hub
import Scenes.Level.Model as LevelModel
import Scenes.Level.Update as Level
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
    , hubModel = Hub.initialState
    , externalAnimations = ""
    }


update : Main.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
update msg model =
    case msg of
        LevelMsg levelMsg ->
            handleLevelMsg levelMsg model

        HubMsg hubMsg ->
            handleHubMsg hubMsg model

        ReceieveExternalAnimations animations ->
            { model | externalAnimations = animations } ! []

        StartLevel progress ->
            model
                ! [ sequenceMs
                        [ ( 600, HubMsg <| SetCurrentLevel <| Just progress )
                        , ( 10, HubMsg BeginSceneTransition )
                        , ( 500, HubMsg <| SetScene Level )
                        , ( 0, LoadLevelData <| getLevelConfig progress model.hubModel )
                        , ( 2500, HubMsg EndSceneTransition )
                        ]
                  ]

        LoadLevelData levelData ->
            handleLoadLevel levelData model

        WindowSize size ->
            { model
                | levelModel = addWindowSizeToLevel size model
                , hubModel = addWindowSizeToHub size model
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


addWindowSizeToHub : Window.Size -> Main.Model -> HubModel.Model
addWindowSizeToHub window { hubModel } =
    { hubModel | window = window }


handleLevelMsg : LevelModel.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleLevelMsg levelMsg model =
    let
        ( levelModel, levelCmd ) =
            Level.update levelMsg model.levelModel
    in
        { model | levelModel = levelModel } ! [ levelCmd |> Cmd.map LevelMsg ]


handleHubMsg : HubModel.Msg -> Main.Model -> ( Main.Model, Cmd Main.Msg )
handleHubMsg hubMsg model =
    let
        ( hubModel, hubCmd ) =
            Hub.update hubMsg model.hubModel
    in
        { model | hubModel = hubModel } ! [ hubCmd |> Cmd.map HubMsg ]


subscriptions : Main.Model -> Sub Main.Msg
subscriptions model =
    Sub.batch
        [ trackWindowSize
        , trackMousePosition model
        , trackMouseDowns
        , receiveExternalAnimations ReceieveExternalAnimations
        , Sub.map HubMsg <| Hub.subscriptions model.hubModel
        ]
