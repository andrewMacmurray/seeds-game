module View exposing (..)

import Scenes.Hub.Types exposing (..)
import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Hub.View exposing (hubView, titleView)
import Scenes.Level.View exposing (levelView)
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
