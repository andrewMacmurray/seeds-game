module Scene exposing
    ( Scene(..)
    , getShared
    , map
    )

import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Retry as Retry
import Scenes.Summary as Summary
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial
import Shared



-- Scene


type Scene
    = Title Title.Model
    | Level Level.Model
    | Tutorial Tutorial.Model
    | Intro Intro.Model
    | Hub Hub.Model
    | Summary Summary.Model
    | Retry Retry.Model


map : (Shared.Data -> Shared.Data) -> Scene -> Scene
map f scene =
    case scene of
        Title model ->
            Title <| Title.updateShared f model

        Level model ->
            Level <| Level.updateShared f model

        Tutorial model ->
            Tutorial <| Tutorial.updateShared f model

        Intro model ->
            Intro <| Intro.updateShared f model

        Hub model ->
            Hub <| Hub.updateShared f model

        Summary model ->
            Summary <| Summary.updateShared f model

        Retry model ->
            Retry <| Retry.updateShared f model


getShared : Scene -> Shared.Data
getShared scene =
    case scene of
        Title model ->
            Title.getShared model

        Level model ->
            Level.getShared model

        Tutorial model ->
            Tutorial.getShared model

        Intro model ->
            Intro.getShared model

        Hub model ->
            Hub.getShared model

        Summary model ->
            Summary.getShared model

        Retry model ->
            Retry.getShared model
