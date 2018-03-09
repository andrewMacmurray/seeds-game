module View exposing (..)

import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Html.Keyed as K
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Hub.View exposing (hubView)
import Scenes.Level.View exposing (levelView)
import Scenes.Retry.View exposing (retryView)
import Scenes.Summary.View exposing (summaryView)
import Scenes.Title.View exposing (titleView)
import Scenes.Tutorial.View exposing (tutorialView)
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Hub.Model -> Html Hub.Msg
view model =
    div []
        [ embeddedAnimations model.xAnimations
        , loadingScreen model
        , renderScene model
        , backdrop
        ]


renderScene : Hub.Model -> Html Hub.Msg
renderScene model =
    let
        keyedDiv =
            K.node "div" []
    in
        case model.scene of
            Hub ->
                hubView model

            Title ->
                titleView model

            Level ->
                keyedDiv
                    [ ( "level", levelView model.levelModel |> Html.map LevelMsg ) ]

            Summary ->
                keyedDiv
                    [ ( "summary", summaryView model )
                    , ( "level", levelView model.levelModel |> Html.map LevelMsg )
                    ]

            Retry ->
                keyedDiv
                    [ ( "retry", retryView model )
                    , ( "level", levelView model.levelModel |> Html.map LevelMsg )
                    ]

            Tutorial ->
                keyedDiv
                    [ ( "tutorial", tutorialView model.tutorialModel |> Html.map TutorialMsg )
                    , ( "level", levelView model.levelModel |> Html.map LevelMsg )
                    ]
