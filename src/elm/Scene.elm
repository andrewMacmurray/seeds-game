module Scene exposing (Scene(..), getShared, map)

import Scenes.Hub.Types exposing (HubModel)
import Scenes.Intro.Types exposing (IntroModel)
import Scenes.Level as Level
import Scenes.Title as Title
import Scenes.Tutorial.Types exposing (TutorialModel)
import Shared


type Scene
    = Title Title.Model
    | Level Level.Model
    | Tutorial TutorialModel
    | Intro IntroModel
    | Hub HubModel
    | Summary Shared.Data
    | Retry Shared.Data


map : (Shared.Data -> Shared.Data) -> Scene -> Scene
map f scene =
    case scene of
        Title titleModel ->
            Title { titleModel | shared = f titleModel.shared }

        Level levelModel ->
            Level { levelModel | shared = f levelModel.shared }

        Tutorial tutorialModel ->
            Tutorial { tutorialModel | shared = f tutorialModel.shared }

        Intro introModel ->
            Intro { introModel | shared = f introModel.shared }

        Hub hubModel ->
            Hub { hubModel | shared = f hubModel.shared }

        Summary shared ->
            Summary <| f shared

        Retry shared ->
            Retry <| f shared


getShared : Scene -> Shared.Data
getShared scene =
    case scene of
        Title { shared } ->
            shared

        Level { shared } ->
            shared

        Tutorial { shared } ->
            shared

        Intro { shared } ->
            shared

        Hub { shared } ->
            shared

        Summary shared ->
            shared

        Retry shared ->
            shared
