module Scenes.Hub.Update exposing (..)

import Data.Hub.Config exposing (hubData)
import Data.Hub.Progress exposing (getLevelConfig, getLevelNumber, getSelectedProgress, handleIncrementProgress)
import Data.Hub.Transition exposing (genRandomBackground)
import Data.Hub.Types exposing (..)
import Data.Ports exposing (getExternalAnimations, receiveExternalAnimations, receiveHubLevelOffset, scrollToHubLevel)
import Helpers.Effect exposing (..)
import Scenes.Hub.Model as Hub exposing (..)
import Window


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
    }



-- Window Size needed as argument for hub scroll subscription


update : Window.Size -> Hub.Msg -> Hub.Model -> ( Hub.Model, Cmd Hub.Msg )
update window msg model =
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
            model ! [ scrollHubToLevel offset window ]

        DomNoOp _ ->
            model ! []


subscriptions : Hub.Model -> Sub Hub.Msg
subscriptions _ =
    receiveHubLevelOffset ReceiveHubLevelOffset
