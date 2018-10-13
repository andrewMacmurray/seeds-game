module View exposing (view)

import Config.Animations exposing (animations)
import Css.Color exposing (darkYellow)
import Css.Style exposing (color, style)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Scene exposing (Scene(..))
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Retry as Retry
import Scenes.Summary as Summary
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial
import Types exposing (Model, Msg(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ animations
        , reset
        , loadingScreen <| Scene.getShared model.scene
        , keyedDiv <| renderScene model.scene
        , backdrop
        ]


keyedDiv : List ( String, Html msg ) -> Html msg
keyedDiv =
    K.node "div" []


renderScene : Scene -> List ( String, Html Msg )
renderScene scene =
    case scene of
        Hub hubModel ->
            [ ( "hub", Hub.view hubModel |> Html.map HubMsg ) ]

        Intro introModel ->
            [ ( "intro", Intro.view introModel |> Html.map IntroMsg ) ]

        Title titleModel ->
            [ ( "title", Title.view titleModel |> Html.map TitleMsg ) ]

        Level levelModel ->
            [ ( "level", Level.view levelModel |> Html.map LevelMsg ) ]

        Tutorial tutorialModel ->
            [ ( "tutorial", Tutorial.view tutorialModel |> Html.map TutorialMsg )
            ]

        Summary summaryModel ->
            [ ( "summary", Summary.view summaryModel ) ]

        Retry retryModel ->
            [ ( "retry", Retry.view retryModel ) ]


reset : Html Msg
reset =
    p
        [ onClick ClearCache
        , class "dib top-0 right-1 tracked pointer f7 absolute z-999"
        , style [ color darkYellow ]
        ]
        [ text "reset" ]
