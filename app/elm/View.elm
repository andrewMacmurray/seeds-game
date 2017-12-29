module View exposing (..)

import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Hub.View exposing (hubView)
import Scenes.Level.View exposing (levelView)
import Scenes.Title.View exposing (titleView)
import Scenes.Tutorial.View exposing (tutorialView)
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Hub.Model -> Html Hub.Msg
view model =
    div []
        [ embeddedAnimations model.externalAnimations
        , loadingScreen model
        , renderScene model
        , backdrop
        ]


renderScene : Hub.Model -> Html Hub.Msg
renderScene model =
    case model.scene of
        Level ->
            levelView model.levelModel |> Html.map LevelMsg

        Hub ->
            hubView model

        Title ->
            titleView model

        Tutorial ->
            div []
                [ tutorialView model.tutorialModel |> Html.map TutorialMsg
                , levelView model.levelModel |> Html.map LevelMsg
                ]
