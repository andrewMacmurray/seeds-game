module View exposing (..)

import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Model exposing (..)
import Scenes.Level.View exposing (level)
import Scenes.Title.View exposing (title)
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loading)


view : Model -> Html Msg
view model =
    div []
        [ embeddedAnimations
        , renderLoading model
        , renderScene model
        , Html.map LevelMsg <| backdrop model.levelModel
        ]


renderLoading : Model -> Html Msg
renderLoading model =
    if model.transitioning then
        loading
    else
        span [] []


renderScene : Model -> Html Msg
renderScene model =
    case model.scene of
        Level ->
            Html.map LevelMsg <| level model.levelModel

        TitleScreen ->
            title model
