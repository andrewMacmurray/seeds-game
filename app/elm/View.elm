module View exposing (..)

import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Model exposing (..)
import Scenes.Hub.View exposing (hub)
import Scenes.Level.Update exposing (levelView)
import Scenes.Title.View exposing (title)
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
    case model.scene of
        Level ->
            levelView model |> Html.map LevelMsg

        Hub ->
            hub model

        Title ->
            title model
