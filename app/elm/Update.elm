module Update exposing (..)

import Model exposing (..)
import Scenes.Level.Update as Level
import Task
import Window exposing (resizes, size)


init : ( Model, Cmd Msg )
init =
    initialModel
        ! [ size |> Task.perform WindowSize
          , Cmd.map LevelMsg Level.initCmds
          ]


initialModel : Model
initialModel =
    { scene = TitleScreen
    , transitioning = False
    , levelModel = Level.initialState
    , window = { height = 0, width = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScene scene ->
            { model | scene = scene } ! []

        Transition bool ->
            { model | transitioning = bool } ! []

        LevelMsg levelMsg ->
            let
                ( levelModel, levelCmd ) =
                    Level.update levelMsg model.levelModel
            in
                { model | levelModel = levelModel } ! [ Cmd.map LevelMsg levelCmd ]

        WindowSize size ->
            { model | window = size } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ resizes WindowSize
        , Sub.map LevelMsg <| Level.subscriptions model.levelModel
        ]
