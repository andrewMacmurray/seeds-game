module Scene exposing
    ( Scene(..)
    , getContext
    , map
    )

import Context exposing (Context)
import Scenes.Garden as Garden
import Scenes.Hub as Hub
import Scenes.Intro as Intro
import Scenes.Level as Level
import Scenes.Retry as Retry
import Scenes.Summary as Summary
import Scenes.Title as Title
import Scenes.Tutorial as Tutorial



-- Scene


type Scene
    = Title Title.Model
    | Level Level.Model
    | Tutorial Tutorial.Model
    | Intro Intro.Model
    | Hub Hub.Model
    | Summary Summary.Model
    | Retry Retry.Model
    | Garden Garden.Model


map : (Context -> Context) -> Scene -> Scene
map f scene =
    case scene of
        Title model ->
            Title <| Title.updateContext f model

        Level model ->
            Level <| Level.updateContext f model

        Tutorial model ->
            Tutorial <| Tutorial.updateContext f model

        Intro model ->
            Intro <| Intro.updateContext f model

        Hub model ->
            Hub <| Hub.updateContext f model

        Summary model ->
            Summary <| Summary.updateContext f model

        Retry model ->
            Retry <| Retry.updateContext f model

        Garden model ->
            Garden <| Garden.updateContext f model


getContext : Scene -> Context
getContext scene =
    case scene of
        Title model ->
            Title.getContext model

        Level model ->
            Level.getContext model

        Tutorial model ->
            Tutorial.getContext model

        Intro model ->
            Intro.getContext model

        Hub model ->
            Hub.getContext model

        Summary model ->
            Summary.getContext model

        Retry model ->
            Retry.getContext model

        Garden model ->
            Garden.getContext model
