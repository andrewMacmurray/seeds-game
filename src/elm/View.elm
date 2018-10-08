module View exposing (view)

import Config.Animations exposing (animations)
import Css.Color exposing (darkYellow)
import Css.Style exposing (color, style)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Scene exposing (Scene(..))
import Scenes.Hub.View exposing (hubView)
import Scenes.Intro.View exposing (introView)
import Scenes.Level.View exposing (levelView)
import Scenes.Retry exposing (retryView)
import Scenes.Summary exposing (summaryView)
import Scenes.Title as Title
import Scenes.Tutorial.View exposing (tutorialView)
import Types exposing (Model, Msg(..))
import Views.Backdrop exposing (backdrop)
import Views.Loading exposing (loadingScreen)


view : Model -> Html Msg
view model =
    div []
        [ animations
        , reset
        , loadingScreen <| Scene.getShared model.scene
        , keyedDiv <| renderScene model
        , backdrop
        ]


keyedDiv : List ( String, Html msg ) -> Html msg
keyedDiv =
    K.node "div" []


renderScene : Model -> List ( String, Html Msg )
renderScene model =
    case model.scene of
        Hub hubModel ->
            [ ( "hub", hubView hubModel |> Html.map HubMsg ) ]

        Intro introModel ->
            [ ( "intro", introView introModel |> Html.map IntroMsg ) ]

        Title titleModel ->
            [ ( "title", Title.view titleModel |> Html.map TitleMsg ) ]

        Level levelModel ->
            [ ( "level", levelView levelModel |> Html.map LevelMsg ) ]

        Summary summaryModel ->
            [ ( "summary", summaryView summaryModel ) ]

        Retry retryModel ->
            [ ( "retry", retryView retryModel ) ]

        Tutorial tutorialModel ->
            [ ( "tutorial", tutorialView tutorialModel |> Html.map TutorialMsg )
            ]


reset : Html Msg
reset =
    p
        [ onClick ClearCache
        , class "dib top-0 right-1 tracked pointer f7 absolute z-999"
        , style [ color darkYellow ]
        ]
        [ text "reset" ]
