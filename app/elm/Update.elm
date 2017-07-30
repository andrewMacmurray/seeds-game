module Update exposing (..)

import Model exposing (..)
import Scenes.Level.Update as Level


init : ( Model, Cmd Msg )
init =
    initialModel ! [ Cmd.map LevelMsg Level.initCmds ]


initialModel : Model
initialModel =
    { scene = TitleScreen
    , transitioning = False
    , levelModel = Level.initialState
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map LevelMsg <| Level.subscriptions model.levelModel
