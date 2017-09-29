module Scenes.Hub.Update exposing (..)

import Data.Hub.Config exposing (hubData)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber, getSelectedProgress, handleIncrementProgress)
import Data.Hub.Transition exposing (genRandomBackground)
import Data.Hub.Types exposing (..)
import Data.Ports exposing (getExternalAnimations, receiveExternalAnimations, receiveHubLevelOffset, scrollToHubLevel)
import Helpers.Effect exposing (..)
import Scenes.Hub.Model as Hub exposing (..)


init : ( Hub.Model, Cmd Hub.Msg )
init =
    initialState ! []


initialState : Hub.Model
initialState =
    { scene = Title
    , sceneTransition = False
    , transitionBackground = Orange
    , progress = ( 1, 1 )
    , currentLevel = Nothing
    , infoWindow = Hidden
    , hubData = hubData
    , window = { height = 0, width = 0 }
    }


update : Hub.Msg -> Hub.Model -> ( Hub.Model, Cmd Hub.Msg )
update msg model =
    case msg of
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
                        , ( 100, ScrollToHubLevel <| getLevelNumber model.progress model.hubData )
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


subscriptions : Hub.Model -> Sub Hub.Msg
subscriptions _ =
    receiveHubLevelOffset ReceiveHubLevelOffset
