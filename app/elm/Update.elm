module Update exposing (..)

import Delay
import Helpers.Window exposing (getWindowSize, trackMouseDowns, trackMousePosition, trackWindowSize)
import Model exposing (..)
import Scenes.Level.Update as Level
import Time exposing (millisecond)


init : ( Model, Cmd Msg )
init =
    initialModel
        ! [ getWindowSize
          , Level.initCmd |> Cmd.map LevelMsg
          ]


initialModel : Model
initialModel =
    { scene = TitleScreen
    , transitioning = False
    , levelModel = Level.initialState
    , window = { height = 0, width = 0 }
    , mouse = { x = 0, y = 0 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScene scene ->
            { model | scene = scene } ! []

        Transition bool ->
            { model | transitioning = bool } ! []

        StartLevel ->
            model
                ! [ Delay.sequence <|
                        Delay.withUnit millisecond
                            [ ( 0, Transition True )
                            , ( 500, SetScene Level )
                            , ( 2500, Transition False )
                            ]
                  ]

        LevelMsg levelMsg ->
            let
                ( levelModel, levelCmd ) =
                    Level.update levelMsg model.levelModel
            in
                { model | levelModel = levelModel } ! [ levelCmd |> Cmd.map LevelMsg ]

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
        , Level.subscriptions model.levelModel |> Sub.map LevelMsg
        ]
