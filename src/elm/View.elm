module View exposing (..)

import Helpers.Animation exposing (embeddedAnimations)
import Html exposing (..)
import Html.Attributes exposing (class)
import Scenes.Hub.Types as Hub exposing (..)
import Scenes.Hub.View exposing (hubView)
import Scenes.Level.View exposing (levelView)
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
        hidden =
            div [ class "dn" ]
    in
        case model.scene of
            Hub ->
                hubView model

            Title ->
                titleView model

            Level ->
                div []
                    [ hidden [ summaryView model ]
                    , hidden [ tutorialView model.tutorialModel |> Html.map TutorialMsg ]
                    , levelView model.levelModel |> Html.map LevelMsg
                    ]

            Summary ->
                div []
                    [ summaryView model
                    , hidden [ tutorialView model.tutorialModel |> Html.map TutorialMsg ]
                    , levelView model.levelModel |> Html.map LevelMsg
                    ]

            Tutorial ->
                div []
                    [ hidden [ summaryView model ]
                    , tutorialView model.tutorialModel |> Html.map TutorialMsg
                    , levelView model.levelModel |> Html.map LevelMsg
                    ]
