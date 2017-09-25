module View exposing (..)

import Data.Hub.Types exposing (..)
import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Model exposing (..)
import Scenes.Hub.View exposing (hubView)
import Scenes.Level.View exposing (levelView)
import Scenes.Title exposing (titleView)
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations model
        , loadingScreen model
        , renderScene model
        , backdrop model.levelModel |> Html.map LevelMsg
        ]


renderScene : Model -> Html Msg
renderScene model =
    case model.hubModel.scene of
        Level ->
            levelView model |> Html.map LevelMsg

        Hub ->
            hubView model.window model.hubModel

        Title ->
            titleView model
