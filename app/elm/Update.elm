module Update exposing (..)

import Data.Hub.LoadLevel exposing (handleLoadLevel)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber, getSelectedProgress, handleIncrementProgress)
import Data.Ports exposing (getExternalAnimations, receiveExternalAnimations, receiveHubLevelOffset, scrollToHubLevel)
import Helpers.Delay exposing (sequenceMs)
import Helpers.Window exposing (getWindowSize, trackMouseDowns, trackMousePosition, trackWindowSize)
import Model exposing (..)
import Data.Hub.Types exposing (..)
import Scenes.Level.Update as Level
import Scenes.Hub.Update as Hub
import Scenes.Hub.Model exposing (HubMsg(..))


init : ( Model, Cmd Msg )
init =
    initialState
        ! [ getWindowSize
          , getExternalAnimations initialState.levelModel.tileSize.y
          ]


initialState : Model
initialState =
    { levelModel = Level.initialState
    , hubModel = Hub.initialState
    , window = { height = 0, width = 0 }
    , mouse = { x = 0, y = 0 }
    , externalAnimations = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        LevelMsg levelMsg ->
            let
                ( levelModel, levelCmd ) =
                    Level.update levelMsg model.levelModel
            in
                { model | levelModel = levelModel } ! [ levelCmd |> Cmd.map LevelMsg ]

        HubMsg hubMsg ->
            let
                ( hubModel, hubCmd ) =
                    Hub.update model.window hubMsg model.hubModel
            in
                { model | hubModel = hubModel } ! [ hubCmd |> Cmd.map HubMsg ]

        WindowSize size ->
            { model | window = size } ! []

        MousePosition position ->
            { model | mouse = position } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trackWindowSize
        , trackMousePosition model
        , trackMouseDowns
        , receiveExternalAnimations ReceieveExternalAnimations
        , Sub.map HubMsg (Hub.subscriptions model.hubModel)
        ]
