module Update exposing (..)

import Model exposing (..)
import Scenes.Level.Update as Level


init : ( Model, Cmd Msg )
init =
    { scene = TitleScreen
    , levelModel = Level.initialState
    }
        ! [ Cmd.map LevelMsg Level.initCmds ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScene scene ->
            { model | scene = scene } ! []

        LevelMsg levelMsg ->
            let
                ( levelModel, levelCmd ) =
                    Level.update levelMsg model.levelModel
            in
                { model | levelModel = levelModel } ! [ Cmd.map LevelMsg levelCmd ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map LevelMsg <| Level.subscriptions model.levelModel
